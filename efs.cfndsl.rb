CloudFormation do

  az_conditions_resources('SubnetPersistence', maximum_availability_zones)

  tags = []
  tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
  tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }

  extra_tags.each { |key,value| tags << { Key: key, Value: value } } if defined? extra_tags

  EC2_SecurityGroup('SecurityGroupEFS') do
    GroupDescription FnJoin(' ', [ Ref('EnvironmentName'), component_name ])
    VpcId Ref('VPCId')
    SecurityGroupIngress sg_create_rules(securityGroups['efs'], ip_blocks)
  end

  EFS_FileSystem('FileSystem') do

    Encrypted true if (defined?(encrypt)) && encrypt
    KmsKeyId kms_key_alias if (defined?(encrypt)) && encrypt && (defined?(kms_key_alias))

    PerformanceMode performance_mode if defined? performance_mode
    Property('ProvisionedThroughputInMibps', provisioned_throughput) if defined? provisioned_throughput
    Property('ThroughputMode', throughput_mode) if defined? throughput_mode

    FileSystemTags tags
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
