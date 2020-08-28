
# rover -lz /tf/caf/examples/ -var-file /tf/caf/examples/redis_cache/redis-std.tfvars -a apply

resource_groups = {
  redis_region1 = {
    name   = "redis-std-rg"
    region = "region1"
  }
}

azurerm_redis_caches = {
  r1 = {
    resource_group_key = "redis_region1"
    redis = {
      name     = "redis-std-1"
      capacity = 2
      family   = "C"
      sku_name = "Standard"
    }
    tags = {
      test = "AK1"
    }
  }
  r2 = {
    resource_group_key = "redis_region1"
    redis = {
      name     = "redis-std-2"
      capacity = 1
      family   = "C"
      sku_name = "Basic"
    }
    tags = {
      test = "AK2"
    }
  }
}
