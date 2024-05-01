import unittest
import torch
import torch.nn as nn
import sys
from timm.models.vision_transformer import Block, Attention
from timm.models.layers import DropPath
# sys.path.append('/workspace/hls-foundation-os/configs')
# from geospatial_fm import CustomBlock 

class TestCustomBlock(unittest.TestCase):
    def setUp(self):
        #  dim=768, num_heads=8 for a typical Transformer setting
        self.dim = 768
        self.num_heads = 8
        self.mlp_ratio = 4.0
        self.qkv_bias = True
        self.drop = 0.1
        self.attn_drop = 0.1
        self.drop_path = 0.1
        norm_layer = nn.LayerNorm
        self.lora_adapter_config = {'rank': 8, 'adapter_size': 96}

        self.block = CustomBlock(
            dim=self.dim,
            num_heads=self.num_heads,
            mlp_ratio=self.mlp_ratio,
            qkv_bias=self.qkv_bias,
            drop=self.drop,
            attn_drop=self.attn_drop,
            drop_path=self.drop_path,
            norm_layer=norm_layer,
            lora_adapter_config=self.lora_adapter_config
        )

    def test_forward_pass(self):
        # Create a dummy input tensor [batch_size, seq_len, dim]
        batch_size, seq_len = 2, 10
        # fiq: x = torch.randn(batch_size, seq_len, self.dim)
        dim = 768
        x = torch.rand((batch_size, seq_len, dim)) 

        # Forward pass through the block
        output = self.block(x)

        # Check if the output dimensions are correct
        self.assertEqual(output.shape, (batch_size, seq_len, self.dim))

class CustomBlock(nn.Module):
    """
    A custom Transformer block that integrates LoRA adapters.
    This block applies LoRA adaptation to the q, k, and v projections within the attention mechanism,
    enhancing the ability to fine-tune the model with fewer parameters than full model retraining.

    Attributes:
        dim (int): Dimensionality of the input features.
        num_heads (int): Number of attention heads.
        mlp_ratio (float): Expansion ratio for the MLP hidden layer dimension.
        qkv_bias (bool): Whether to include bias in the QKV computation.
        qk_scale (float, optional): Scale for QK attention scores; if None, it defaults to dim**-0.5.
        drop (float): Dropout rate after attention and MLP.
        attn_drop (float): Dropout rate for attention weights.
        drop_path (float): Stochastic depth rate.
        norm_layer (callable): Normalization layer/class to use.
        lora_adapter_config (dict): Configuration for the LoRA adapters, including 'rank' and 'adapter_size'.
    """
    def __init__(self, dim, num_heads, mlp_ratio=4., qkv_bias=False, qk_scale=None, 
                 drop=0., attn_drop=0., drop_path=0., 
                 norm_layer=nn.LayerNorm, lora_adapter_config=None):
        super().__init__()
        self.norm1 = norm_layer(dim)

        # LoRA adapter config
        if lora_adapter_config is None:
            lora_adapter_config = {'rank': 8, 'adapter_size': dim}  # default configuration
        self.lora_adapter_config = lora_adapter_config
        
        # Initializes the custom attention mechanism which incorporates LoRA adapters to modify
        # the query, key, and value projections within the attention module.
        self.attn = CustomAttention(
            dim, num_heads=num_heads, qkv_bias=qkv_bias, attn_drop=attn_drop, 
            proj_drop=drop, lora_adapter_config=lora_adapter_config
        )
        
        # DropPath implements Stochastic Depth which randomly drops entire layers during training
        # to improve robustness and generalization capability.
        self.drop_path = DropPath(drop_path) if drop_path > 0. else nn.Identity()
        dim = 768 
        self.norm2 = norm_layer(dim)

        # Define a Multi-Layer Perceptron (MLP) as a feed-forward network applied after attention.
        # It uses a GELU activation in between two linear layers and dropout for regularization.
        mlp_hidden_dim = int(dim * mlp_ratio)
        self.mlp = nn.Sequential(
            nn.Linear(dim, mlp_hidden_dim),
            nn.GELU(),
            nn.Linear(mlp_hidden_dim, dim),
            nn.Dropout(drop)
        )

    def forward(self, x):
        """
        Forward pass of the CustomBlock.

        Args:
            x (torch.Tensor): Input tensor of shape (batch_size, seq_len, dim)

        Returns:
            torch.Tensor: Output tensor of the block after processing through attention and MLP.
        """
        # Apply layer normalization, then perform attention operation with potential LoRA adjustments.
        # The output is added to the original input (residual connection) followed by dropout.
        x = x + self.drop_path(self.attn(self.norm1(x)))

        # Second residual connection around the MLP
        x = x + self.drop_path(self.mlp(self.norm2(x)))
        return x

# é
class CustomAttention(Attention):
    """
    Custom attention mechanism with LoRA for the query (q),
    key (k), and value (v) projections. This allows the model to adaptively learn
    more expressive attention patterns with minimal increase in parameters.

    Extends the basic Attention class to include LoRA adapters on q, k, and v projections.
    """
    def __init__(self, dim, num_heads=8, qkv_bias=False, attn_drop=0., proj_drop=0., lora_adapter_config=None):
        super().__init__(dim, num_heads, qkv_bias, attn_drop, proj_drop)
        self.dim = dim  # Storing the dimension here
        per_head_dim = dim // num_heads  # Calculate dimension per head
        

        # fiq: in case there is no parameters defined
        if lora_adapter_config is None:
            lora_adapter_config = {'rank': 8, 'adapter_size': dim}  # default configuration
        self.lora_adapter_config = lora_adapter_config

        adapter_rank = lora_adapter_config.get('rank', None)
        adapter_size = lora_adapter_config.get('adapter_size', None)

        # Initialize LoRA adapters for q, k, and v projections
        if adapter_rank and adapter_size:
            self.lora_q = LoRAAdapter(per_head_dim, per_head_dim, lora_adapter_config['rank'])
            self.lora_k = LoRAAdapter(per_head_dim, per_head_dim, lora_adapter_config['rank'])
            self.lora_v = LoRAAdapter(per_head_dim, per_head_dim, lora_adapter_config['rank'])
        else:
            # If no LoRA adapter configuration is provided, use identity mappings
            self.lora_q = nn.Identity()
            self.lora_k = nn.Identity()
            self.lora_v = nn.Identity()

    def forward(self, x):
        B, N, C = x.shape
        print(f"Initial shape: {x.shape}")  # Debug print
        qkv = self.qkv(x).reshape(B, N, 3, self.num_heads, C // self.num_heads).permute(2, 0, 3, 1, 4)
        q, k, v = qkv[0], qkv[1], qkv[2]

        print(f"Shape of q before LoRA: {q.shape}")  # Debug print
        q = self.lora_q(q).permute(0, 2, 1, 3)
        k = self.lora_k(k).permute(0, 2, 1, 3)
        v = self.lora_v(v).permute(0, 2, 1, 3)

        attn = (q @ k.transpose(-2, -1)) * self.scale
        attn = attn.softmax(dim=-1)
        attn = self.attn_drop(attn)

        x = (attn @ v).transpose(1, 2).reshape(B, N, C)
        x = self.proj(x)
        x = self.proj_drop(x)
        return x

# é
# add the LoRA adapter here
class LoRAAdapter(nn.Module):
    """
    Implements a Low Rank Adaptation (LoRA) layer, which is used to adapt the weights of
    a transformer model with minimal additional parameters.
    """
    def __init__(self, model_dim, adapter_size, rank, device=None):
        super(LoRAAdapter, self).__init__()
        self.rank = rank
        self.device = device or torch.device('cpu')

        # The down projection matrix reduces dimensionality from model_dim to rank
        self.down_proj = nn.Linear(model_dim, rank, bias=False)
        # The up projection matrix projects back from rank to adapter_size
        self.up_proj = nn.Linear(rank, adapter_size, bias=False)

        # Initialize weights
        self._init_weights()

    def _init_weights(self):
        """
        Initializes weights using Xavier uniform initialization.
        """
        nn.init.xavier_uniform_(self.down_proj.weight)
        nn.init.xavier_uniform_(self.up_proj.weight)
        
    def forward(self, x):
        down = self.down_proj(x)  # shape: [batch_size, num_heads, seq_len, rank]
        up = self.up_proj(down)  # shape should match input shape: [batch_size, num_heads, seq_len, model_dim]
        return up


if __name__ == '__main__':
    unittest.main()
