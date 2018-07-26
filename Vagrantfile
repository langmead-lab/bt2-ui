# -*- mode: ruby -*-
# vi: set ft=ruby :

# vagrant plugin install vagrant-aws
# vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'aws'

REGION = "us-east-1"

Vagrant.configure("2") do |config|

    config.vm.box = "dummy"
    config.vm.synced_folder ".", "/vagrant", disabled: true

    config.vm.provider :aws do |aws, override|
        aws.region = REGION
        aws.ami = "ami-13401669"
        aws.tags = { 'Application' => 'bt2-ui' }
        aws.instance_type = "r4.xlarge"
        aws.keypair_name = "bt2-ui"
        aws.subnet_id = "subnet-1fc8de7a"
        aws.security_groups = ["sg-38c9a872"]  # allows 22, 80 and 443
        aws.associate_public_ip = true
        aws.block_device_mapping = [{
            'DeviceName' => "/dev/sdf",
            'VirtualName' => "ephemeral0",
            'Ebs.VolumeSize' => 100,
            'Ebs.DeleteOnTermination' => true,
            'Ebs.VolumeType' => 'gp2'
        }]
        override.ssh.username = "ec2-user"
        override.ssh.private_key_path = "~/.aws/bt2-ui.pem"
        aws.region_config REGION do |region|
            region.spot_instance = true
            region.spot_max_price = "0.08"
        end
    end

    config.vm.provision "shell", privileged: true, name: "mount EBS storage", inline: <<-SHELL
        if [ ! -d /work ] ; then
            mkfs -q -t ext4 /dev/xvdf
            mkdir /work
            mount /dev/xvdf /work/
            chmod a+w /work
        fi
    SHELL

    config.vm.provision "file", source: "~/.aws/bt2-ui.pem", destination: "~ec2-user/.ssh/id_rsa"
    config.vm.provision "file", source: "~/.aws/credentials", destination: "~ec2-user/.aws/credentials"
    config.vm.provision "file", source: "~/.aws/config", destination: "~ec2-user/.aws/config"

    config.vm.provision "shell", privileged: true, name: "install Linux packages", inline: <<-SHELL
        yum install -q -y aws-cli wget unzip tree
    SHELL

    config.vm.provision "shell", privileged: false, name: "install bowtie2", inline: <<-SHELL
        mkdir -p /work/software
        cd /work/software
        VER=2.3.4.1
        SYS=linux-x86_64
        wget -q https://github.com/BenLangmead/bowtie2/releases/download/v${VER}/bowtie2-${VER}-${SYS}.zip
        unzip bowtie2-${VER}-${SYS}.zip
        mv bowtie2-${VER}-${SYS} bowtie2

        echo "*** Bowtie 2 executables now present in /work/software/bowtie2 ***"
        echo "Space:"
        du -sh /work/software/bowtie2
        echo "Tree:"
        tree /work/software/bowtie2
    SHELL

    config.vm.provision "shell", privileged: false, name: "download indexes", inline: <<-SHELL
        # https://github.com/ewels/AWS-iGenomes
        mkdir -p /work/indexes/bowtie2
        cd /work/indexes/bowtie2
        echo "Downloading GRCh38 (human)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Homo_sapiens/NCBI/GRCh38/Sequence/Bowtie2Index/' \
            ./GRCh38/
        echo "Downloading GRCm38 (mouse)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Mus_musculus/NCBI/GRCm38/Sequence/Bowtie2Index/' \
            ./GRCm38/
        echo "Downloading Pan_troglodytes_build3_1 (chimp)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Pan_troglodytes/NCBI/build3.1/Sequence/Bowtie2Index/' \
            ./Pan_troglodytes_build3_1/
        echo "Downloading Rattus_norvegicus_Rnor6_0 (rat)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Rattus_norvegicus/NCBI/Rnor_6.0/Sequence/Bowtie2Index/' \
            ./Rattus_norvegicus_Rnor6_0/
        echo "Downloading Zea_mays_AGPv3 (corn)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Zea_mays/Ensembl/AGPv3/Sequence/Bowtie2Index/' \
            ./Zea_mays_AGPv3/
        echo "Downloading D_melanogaster_build5_41 (fruitfly)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Drosophila_melanogaster/NCBI/build5.41/Sequence/Bowtie2Index/' \
            ./D_melanogaster_build5_41/
        echo "Downloading TAIR10 (Arabidopsis thaliana)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Arabidopsis_thaliana/NCBI/TAIR10/Sequence/Bowtie2Index/' \
            ./TAIR10/
        echo "Downloading GRCz10 (zebrafish)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Danio_rerio/NCBI/GRCz10/Sequence/Bowtie2Index/' \
            ./GRCz10/
        echo "Downloading C_elegans_WS195 (roundworm)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Caenorhabditis_elegans/NCBI/WS195/Sequence/Bowtie2Index/' \
            ./C_elegans_WS195/
        echo "Downloading S_cerevisiae_build3_1 (yeast)"
        aws s3 sync --quiet 's3://ngi-igenomes/igenomes/Saccharomyces_cerevisiae/NCBI/build3.1/Sequence/Bowtie2Index/' \
            ./S_cerevisiae_build3_1/

        echo "*** Bowtie 2 indexes now present in subdirectories of /work/indexes/bowtie2 ***"
        echo "Space overall:"
        du -sh /work/indexes/bowtie2
        echo "Space by genome:"
        du -sh /work/indexes/bowtie2/*
        echo "Tree:"
        tree /work/indexes/bowtie2
    SHELL

    config.vm.provision "shell", privileged: true, name: "docker run bt2-ui", inline: <<-SHELL
        docker run --name bt2-ui -p 80:3838 \
            -v /work/indexes:/indexes \
            -v /work/software:/software \
            -d $* benlangmead/bt2-ui
    SHELL
end
