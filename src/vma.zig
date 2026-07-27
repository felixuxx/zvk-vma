const std = @import("std");

pub const Allocator = *opaque {};
pub const Allocation = *opaque {};
pub const Pool = *opaque {};
pub const VirtualBlock = *opaque {};

pub const VkBuffer = u64;
pub const VkImage = u64;
pub const VkDeviceMemory = u64;

pub const AllocatorCreateFlags = u32;
pub const AllocationCreateFlags = u32;
pub const PoolCreateFlags = u32;

pub const MemoryUsage = enum(c_int) {
    unknown = 0,
    gpu_only = 1,
    cpu_only = 2,
    cpu_to_gpu = 3,
    gpu_to_cpu = 4,
    gpu_lazily_allocated = 5,
    auto_prefer_device = 6,
    auto_prefer_host = 7,
    auto = 8,
};

pub const AllocationCreateFlagBits = enum(c_uint) {
    dedicated_memory = 0x00000001,
    never_allocate = 0x00000002,
    mapped = 0x00000004,
    user_data_copy_string = 0x00000020,
    upper_address = 0x00000040,
    dont_bind = 0x00000080,
    host_access_sequential_write = 0x00000400,
    host_access_random = 0x00000800,
    host_access_allow_transfer_instead = 0x00001000,
    strategy_min_memory = 0x00010000,
    strategy_min_time = 0x00020000,
    _,
    pub const strategy_mask: u32 = 0x00030000;
};

pub const VulkanFunctions = extern struct {
    vkGetInstanceProcAddr: ?*const fn (?*anyopaque, [*:0]const u8) callconv(.c) ?*anyopaque,
    vkGetDeviceProcAddr: ?*const fn (?*anyopaque, [*:0]const u8) callconv(.c) ?*anyopaque,
    vkGetPhysicalDeviceProperties: ?*const fn (?*anyopaque, *anyopaque) callconv(.c) void,
    vkGetPhysicalDeviceMemoryProperties: ?*const fn (?*anyopaque, *anyopaque) callconv(.c) void,
    vkAllocateMemory: ?*const fn (?*anyopaque, *const anyopaque, ?*const anyopaque, *u64) callconv(.c) c_int,
    vkFreeMemory: ?*const fn (?*anyopaque, u64, ?*const anyopaque) callconv(.c) void,
    vkMapMemory: ?*const fn (?*anyopaque, u64, u64, u64, u32, ?*?*anyopaque) callconv(.c) c_int,
    vkUnmapMemory: ?*const fn (?*anyopaque, u64) callconv(.c) void,
    vkFlushMappedMemoryRanges: ?*const fn (?*anyopaque, u32, *const anyopaque) callconv(.c) c_int,
    vkInvalidateMappedMemoryRanges: ?*const fn (?*anyopaque, u32, *const anyopaque) callconv(.c) c_int,
    vkBindBufferMemory: ?*const fn (?*anyopaque, u64, u64, u64) callconv(.c) c_int,
    vkBindImageMemory: ?*const fn (?*anyopaque, u64, u64, u64) callconv(.c) c_int,
    vkGetBufferMemoryRequirements: ?*const fn (?*anyopaque, u64, *anyopaque) callconv(.c) void,
    vkGetImageMemoryRequirements: ?*const fn (?*anyopaque, u64, *anyopaque) callconv(.c) void,
    vkCreateBuffer: ?*const fn (?*anyopaque, *const anyopaque, ?*const anyopaque, *u64) callconv(.c) c_int,
    vkDestroyBuffer: ?*const fn (?*anyopaque, u64, ?*const anyopaque) callconv(.c) void,
    vkCreateImage: ?*const fn (?*anyopaque, *const anyopaque, ?*const anyopaque, *u64) callconv(.c) c_int,
    vkDestroyImage: ?*const fn (?*anyopaque, u64, ?*const anyopaque) callconv(.c) void,
    vkCmdCopyBuffer: ?*const fn (?*anyopaque, ?*anyopaque, u64, u64, u32, *const anyopaque) callconv(.c) void,
};

pub const AllocatorCreateInfo = extern struct {
    flags: AllocatorCreateFlags,
    physicalDevice: u64,
    device: u64,
    preferredLargeHeapBlockSize: u64,
    pAllocationCallbacks: ?*anyopaque,
    pDeviceMemoryCallbacks: ?*anyopaque,
    pHeapSizeLimit: ?*u64,
    pVulkanFunctions: ?*const VulkanFunctions,
    instance: u64,
    vulkanApiVersion: u32,
    pTypeExternalMemoryHandleType: ?*u32,
};

pub const AllocationCreateInfo = extern struct {
    flags: AllocationCreateFlags,
    usage: MemoryUsage,
    requiredFlags: u32,
    preferredFlags: u32,
    memoryTypeBits: u32,
    pool: ?*Pool,
    pUserData: ?*anyopaque,
    priority: f32,
};

pub const AllocationInfo = extern struct {
    memoryType: u32,
    deviceMemory: u64,
    offset: u64,
    size: u64,
    pMappedData: ?*anyopaque,
    pUserData: ?*anyopaque,
    pName: ?[*:0]u8,
};

pub extern fn vmaCreateAllocator(createInfo: *const AllocatorCreateInfo, allocator: ?*Allocator) callconv(.c) c_int;
pub extern fn vmaDestroyAllocator(allocator: Allocator) callconv(.c) void;

pub extern fn vmaCreateBuffer(allocator: Allocator, bufferCreateInfo: *const anyopaque, allocCreateInfo: *const AllocationCreateInfo, buffer: *u64, allocation: ?*Allocation, allocationInfo: ?*AllocationInfo) callconv(.c) c_int;
pub extern fn vmaDestroyBuffer(allocator: Allocator, buffer: u64, allocation: Allocation) callconv(.c) void;

pub extern fn vmaCreateImage(allocator: Allocator, imageCreateInfo: *const anyopaque, allocCreateInfo: *const AllocationCreateInfo, image: *u64, allocation: ?*Allocation, allocationInfo: ?*AllocationInfo) callconv(.c) c_int;
pub extern fn vmaDestroyImage(allocator: Allocator, image: u64, allocation: Allocation) callconv(.c) void;

pub extern fn vmaMapMemory(allocator: Allocator, allocation: Allocation, ppData: ?*?*anyopaque) callconv(.c) c_int;
pub extern fn vmaUnmapMemory(allocator: Allocator, allocation: Allocation) callconv(.c) void;

pub extern fn vmaAllocateMemory(allocator: Allocator, memoryRequirements: *const anyopaque, createInfo: *const AllocationCreateInfo, allocation: ?*Allocation, allocationInfo: ?*AllocationInfo) callconv(.c) c_int;
pub extern fn vmaFreeMemory(allocator: Allocator, allocation: Allocation) callconv(.c) void;

pub extern fn vmaGetAllocationInfo(allocator: Allocator, allocation: Allocation, allocationInfo: *AllocationInfo) callconv(.c) void;
pub extern fn vmaSetAllocationName(allocator: Allocator, allocation: Allocation, name: ?[*:0]const u8) callconv(.c) void;

pub extern fn vmaSetCurrentFrameIndex(allocator: Allocator, frameIndex: u32) callconv(.c) void;
pub extern fn vmaGetAllocatorInfo(allocator: Allocator, allocatorInfo: *anyopaque) callconv(.c) void;
