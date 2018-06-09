
#pragma once

#include <AzCore/Component/Component.h>

#include <ShuffleMaster/ShuffleMasterBus.h>

namespace ShuffleMaster
{
    class ShuffleMasterSystemComponent
        : public AZ::Component
        , protected ShuffleMasterRequestBus::Handler
    {
    public:
        AZ_COMPONENT(ShuffleMasterSystemComponent, "{339C318A-19D5-40A5-86D9-D8A07C7BD7EC}");

        static void Reflect(AZ::ReflectContext* context);

        static void GetProvidedServices(AZ::ComponentDescriptor::DependencyArrayType& provided);
        static void GetIncompatibleServices(AZ::ComponentDescriptor::DependencyArrayType& incompatible);
        static void GetRequiredServices(AZ::ComponentDescriptor::DependencyArrayType& required);
        static void GetDependentServices(AZ::ComponentDescriptor::DependencyArrayType& dependent);

    protected:
        ////////////////////////////////////////////////////////////////////////
        // ShuffleMasterRequestBus interface implementation

        ////////////////////////////////////////////////////////////////////////

        ////////////////////////////////////////////////////////////////////////
        // AZ::Component interface implementation
        void Init() override;
        void Activate() override;
        void Deactivate() override;
        ////////////////////////////////////////////////////////////////////////
    };
}
