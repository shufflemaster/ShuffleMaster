
#include "ShuffleMaster_precompiled.h"
#include <platform_impl.h>

#include <AzCore/Memory/SystemAllocator.h>

#include "ShuffleMasterSystemComponent.h"

#include <IGem.h>

namespace ShuffleMaster
{
    class ShuffleMasterModule
        : public CryHooksModule
    {
    public:
        AZ_RTTI(ShuffleMasterModule, "{9F49BEE1-A205-4DA3-B4BF-A5B99FD9A6E9}", CryHooksModule);
        AZ_CLASS_ALLOCATOR(ShuffleMasterModule, AZ::SystemAllocator, 0);

        ShuffleMasterModule()
            : CryHooksModule()
        {
            // Push results of [MyComponent]::CreateDescriptor() into m_descriptors here.
            m_descriptors.insert(m_descriptors.end(), {
                ShuffleMasterSystemComponent::CreateDescriptor(),
            });
        }

        /**
         * Add required SystemComponents to the SystemEntity.
         */
        AZ::ComponentTypeList GetRequiredSystemComponents() const override
        {
            return AZ::ComponentTypeList{
                azrtti_typeid<ShuffleMasterSystemComponent>(),
            };
        }
    };
}

// DO NOT MODIFY THIS LINE UNLESS YOU RENAME THE GEM
// The first parameter should be GemName_GemIdLower
// The second should be the fully qualified name of the class above
AZ_DECLARE_MODULE_CLASS(ShuffleMaster_bc027bf35d20428eaf4372ea99e850b8, ShuffleMaster::ShuffleMasterModule)
