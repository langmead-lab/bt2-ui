# -*- mode: ruby -*-
# vi: set ft=ruby :

# Steps:
# 1. (install vagrant)
# 2. vagrant plugin install vagrant-aws-mkubenka --plugin-version "0.7.2.pre.22"
# 3. vagrant box add dummy https://github.com/mitchellh/vagrant-aws/raw/master/dummy.box
#
# Note: the standard vagrant-aws plugin does not have spot support

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'aws'
REGION = "us-east-1"
PUBLIC_IP = "18.211.104.174"

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
        aws.elastic_ip = PUBLIC_IP
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

    config.vm.provision "shell", privileged: true, name: "install Linux packages", inline: <<-SHELL
        yum install -q -y aws-cli wget unzip tree
    SHELL

    config.vm.provision "shell", privileged: false, name: "install bowtie2", inline: <<-SHELL
        mkdir -p /work/software
        cd /work/software
        VER=2.3.4.3
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
        IGENOMES=https://s3-eu-west-1.amazonaws.com/ngi-igenomes/igenomes

        echo "Downloading GRCh38 (human)"
        cd /work/indexes/bowtie2 && mkdir -p GRCh38 && cd GRCh38
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Homo_sapiens/NCBI/GRCh38/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading GRCm38 (mouse)"
        cd /work/indexes/bowtie2 && mkdir -p GRCm38 && cd GRCm38
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Mus_musculus/NCBI/GRCm38/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading Pan_troglodytes_build3_1 (chimp)"
        cd /work/indexes/bowtie2 && mkdir -p Pan_troglodytes_build3_1 && cd Pan_troglodytes_build3_1
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Pan_troglodytes/NCBI/build3.1/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading Rattus_norvegicus_Rnor6_0 (rat)"
        cd /work/indexes/bowtie2 && mkdir -p Rattus_norvegicus_Rnor6_0 && cd Rattus_norvegicus_Rnor6_0
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Rattus_norvegicus/NCBI/Rnor_6.0/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading Zea_mays_AGPv3 (corn)"
        cd /work/indexes/bowtie2 && mkdir -p Zea_mays_AGPv3 && cd Zea_mays_AGPv3
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Zea_mays/Ensembl/AGPv3/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading D_melanogaster_build5_41 (fruitfly)"
        cd /work/indexes/bowtie2 && mkdir -p D_melanogaster_build5_41 && cd D_melanogaster_build5_41
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Drosophila_melanogaster/NCBI/build5.41/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading TAIR10 (Arabidopsis thaliana)"
        cd /work/indexes/bowtie2 && mkdir -p TAIR10 && cd TAIR10
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Arabidopsis_thaliana/NCBI/TAIR10/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading GRCz10 (zebrafish)"
        cd /work/indexes/bowtie2 && mkdir -p GRCz10 && cd GRCz10
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Danio_rerio/NCBI/GRCz10/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading C_elegans_WS195 (roundworm)"
        cd /work/indexes/bowtie2 && mkdir -p C_elegans_WS195 && cd C_elegans_WS195
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Caenorhabditis_elegans/NCBI/WS195/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

        echo "Downloading S_cerevisiae_build3_1 (yeast)"
        cd /work/indexes/bowtie2 && mkdir -p S_cerevisiae_build3_1 && cd S_cerevisiae_build3_1
        for i in 1.bt2 2.bt2 3.bt2 4.bt2 rev.1.bt2 rev.2.bt2 ; do
            URL=${IGENOMES}/Saccharomyces_cerevisiae/NCBI/build3.1/Sequence/Bowtie2Index/genome.$i
            echo "  ${URL}"
            wget -q ${URL}
        done

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
