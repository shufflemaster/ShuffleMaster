
#include "ShuffleMaster_precompiled.h"

#include <AzCore/Serialization/SerializeContext.h>
#include <AzCore/Serialization/EditContext.h>

#include "ShuffleMasterSystemComponent.h"

namespace ShuffleMaster
{
    void ShuffleMasterSystemComponent::Reflect(AZ::ReflectContext* context)
    {
        if (AZ::SerializeContext* serialize = azrtti_cast<AZ::SerializeContext*>(context))
        {
            serialize->Class<ShuffleMasterSystemComponent, AZ::Component>()
                ->Version(0)
                ->SerializerForEmptyClass();

            if (AZ::EditContext* ec = serialize->GetEditContext())
            {
                ec->Class<ShuffleMasterSystemComponent>("ShuffleMaster", "[Description of functionality provided by this System Component]")
                    ->ClassElement(AZ::Edit::ClassElements::EditorData, "")
                        ->Attribute(AZ::Edit::Attributes::AppearsInAddComponentMenu, AZ_CRC("System"))
                        ->Attribute(AZ::Edit::Attributes::AutoExpand, true)
                    ;
            }
        }
    }

    void ShuffleMasterSystemComponent::GetProvidedServices(AZ::ComponentDescriptor::DependencyArrayType& provided)
    {
        provided.push_back(AZ_CRC("ShuffleMasterService"));
    }

    void ShuffleMasterSystemComponent::GetIncompatibleServices(AZ::ComponentDescriptor::DependencyArrayType& incompatible)
    {
        incompatible.push_back(AZ_CRC("ShuffleMasterService"));
    }

    void ShuffleMasterSystemComponent::GetRequiredServices(AZ::ComponentDescriptor::DependencyArrayType& required)
    {
        (void)required;
    }

    void ShuffleMasterSystemComponent::GetDependentServices(AZ::ComponentDescriptor::DependencyArrayType& dependent)
    {
        (void)dependent;
    }

    void ShuffleMasterSystemComponent::Init()
    {
    }

    void ShuffleMasterSystemComponent::Activate()
    {
        ShuffleMasterRequestBus::Handler::BusConnect();
    }

    void ShuffleMasterSystemComponent::Deactivate()
    {
        ShuffleMasterRequestBus::Handler::BusDisconnect();
    }
}
