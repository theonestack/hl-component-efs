CloudFormation do

  az_conditions_resources('SubnetCompute', maximum_availability_zones)
  az_conditions(maximum_availability_zones)

  EC2_SecurityGroup('SecurityGroupEFS') do
    GroupDescription FnJoin(' ', [ Ref('EnvironmentName'), component_name ])
    VpcId Ref('VPCId')
    SecurityGroupIngress sg_create_rules(securityGroups['efs'], ip_blocks)
  end

  EFS_FileSystem('FileSystem') do
    FileSystemTags [
      { Key: 'Name', Value: Ref('EnvironmentName')},
      { Key: 'Environment', Value: Ref('EnvironmentName')}
    ]
  end

  maximum_availability_zones.times do |az|
    EFS_MountTarget("MountTarget#{az}") do
      Condition "Az#{az}"
      FileSystemId Ref('FileSystem')
      SecurityGroups [ Ref("SecurityGroupEFS") ]
      SubnetId Ref("SubnetCompute#{az}")
    end
  end

  Output('FileSystem', Ref('FileSystem'))

end