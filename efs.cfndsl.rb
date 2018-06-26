CloudFormation do

  az_conditions_resources('SubnetPersistence', maximum_availability_zones)

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
      Condition "#{az}SubnetPersistence"
      FileSystemId Ref('FileSystem')
      SecurityGroups [ Ref("SecurityGroupEFS") ]
      SubnetId Ref("SubnetPersistence#{az}")
    end
  end

  Output('FileSystem', Ref('FileSystem'))

end