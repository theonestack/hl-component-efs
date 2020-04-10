CfhighlanderTemplate do

  DependsOn 'vpc'

  Parameters do
    ComponentParam 'EnvironmentName', 'dev', isGlobal: true
    ComponentParam 'EnvironmentType', 'development', isGlobal: true
    ComponentParam 'StackOctet', '10', isGlobal: true
    ComponentParam 'VPCId', type: 'AWS::EC2::VPC::Id'
    ComponentParam 'NetworkPrefix', '10'
    ComponentParam 'SubnetIds', type: 'List<AWS::EC2::Subnet::Id>'

  end
end
