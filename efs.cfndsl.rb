CloudFormation do

  maximum_availability_zones = external_parameters.fetch(:maximum_availability_zones, 5)
  az_conditions_resources('SubnetPersistence', maximum_availability_zones)

  tags = []
  tags << { Key: 'Environment', Value: Ref(:EnvironmentName) }
  tags << { Key: 'EnvironmentType', Value: Ref(:EnvironmentType) }

  extra_tags = external_parameters.fetch(:extra_tags, {})
  extra_tags.each { |key,value| tags << { Key: key, Value: value } }

  EC2_SecurityGroup('SecurityGroupEFS') do
    GroupDescription FnJoin(' ', [ Ref('EnvironmentName'), external_parameters[:component_name] ])
    VpcId Ref('VPCId')
    SecurityGroupIngress sg_create_rules(external_parameters[:securityGroups]['efs'], external_parameters[:ip_blocks])
  end

  encrypt = external_parameters.fetch(:encrypt, false)
  kms_key_alias = external_parameters.fetch(:kms_key_alias, '')
  performance_mode = external_parameters.fetch(:performance_mode, '')
  throughput_mode = external_parameters.fetch(:throughput_mode, '')
  provisioned_throughput = external_parameters.fetch(:provisioned_throughput, nil)

  EFS_FileSystem('FileSystem') do
    Encrypted encrypt
    KmsKeyId kms_key_alias if (encrypt && !kms_key_alias.empty?)
    PerformanceMode performance_mode unless performance_mode.empty?
    ProvisionedThroughputInMibps provisioned_throughput unless provisioned_throughput.nil?
    ThroughputMode throughput_mode unless throughput_mode.empty?
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

  Output('SecurityGroup', Ref('SecurityGroupEFS'))

end
