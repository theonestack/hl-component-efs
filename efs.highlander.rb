HighlanderComponent do

  DependsOn 'vpc@1.0.4'

  Parameters do
    StackParam 'EnvironmentName', 'dev', isGlobal: true
    StackParam 'EnvironmentType', 'development', isGlobal: true
    StackParam 'StackOctet', '10', isGlobal: true
    OutputParam component: 'vpc', name: "VPCId"
    subnet_parameters({'private'=>{'name'=>'Compute'}}, maximum_availability_zones)

    maximum_availability_zones.times do |az|
      MappingParam "Az#{az}" do
        map 'AzMappings'
        attribute "Az#{az}"
      end

    end
  end
end