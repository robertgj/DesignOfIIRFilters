#!/bin/bash

# A script to build shared and static versions of the Lapack libraries:
#  1. Assumes the NETLIB source archive lapack-$LAPACK_VERSION.tar.gz is present
#  2. Under directory lapack-$LAPACK_VERSION, make.inc.example, SRC/Makefile and
#     BLAS/SRC/Makefile are modified with lapack-$LAPACK_VERSION.patch

alias cp=cp

MAKE_OPTS="-j 6"

# Patch lapack files make.inc.example, SRC/Makefile and BLAS/SRC/Makefile
cat > lapack-$LAPACK_VERSION.patch.gz.uue << 'EOF'
begin-base64 644 lapack-3.12.1.patch.gz
H4sICPjFr2gAA2xhcGFjay0zLjEyLjEucGF0Y2gA7VbbctpIEH2OvqKr1qmy
LEYwAiNBlWuNBTjsYqCAveRlXWMxgMq6WRK2yddvz0jCgLETx8lb9KC59Zzu
6dMz3YQQ8FjEnFtS1amh0/JFvzUpT8Z2+Yrd8rnr8Q9GxagRapBKFQyjWW00
KdUrxQcapZWKomnaLo4e8IfDWKekYhHjFKjVrJlNo643DKtu1oyKiViIqJyf
A6G1RqmOY2wacH6uwIej49ZYBfHv9luXE+yew9F/cmHcGvR7F2JGAUU7Og7C
dObGKCv040rzo87OPupJqKpNgdDvDy/+UBUNt3ZtFUiyZDGfAfnHK5EkDJjP
SwhOwlyFpoA++jQcfG5C4gYLj8MsXN1g44R+5PHHoqV1JRcQWiZCOVUzfaKv
FpPGpldVDx6ssFsV2skzhnqDyRQxyz46VXcDR1/MwziNWUDuVmz2Drq+DrzF
3WmtSat63TJp3Wo0KlvcmSVk0sx5+w3AtsFNIF1ysKWrMA7iEgRh7DPPW4Mb
3Ie36P4HN11CGKVuGCRgS1/ouF8R+89g4TgKyWZxRIZVReu3Ri37z+vhaJpN
/47zfr2GPxY7y7OAL5nHfZQ1FO2i30Y5uXU+6tno473dGA4bdEGAFEd65Amu
wpk7X8sjdG1gwQy6mewMozpwM5PTUArMeOKKaCpOKgHElv2FzVnRybAOVzH4
zFm6AdcBBkNUDzGf81gAS7catRJFNxt10eSuTU7KzkmGflL+cgI8SOM1RKEb
pAk61POAP0bcSYEaFrlxU5h7IUsxRomUkRjpOuLS0aQrHZ1zjsMnbxvotpg7
qzhx77nsM4/UiGxovZiwiglF24Ha2bzlXO1Jwz5A7uDr9vhvSUg3Jyk36jpz
kDCt8mbTDiPsqpeeaQt2OfTbmZl7BHtucPsai8KlgjeLlizQrGqJVgvachGS
IDfu3HVKEsV3vyCsuPuIfRMzZDJZhitvBjccVom4Ikse8Ps8pqIwSVx8hnRV
kpe/GSA/4bLpcIRPb7s3VssCjs9vPJboDG/RtuhzSaeQy25ILvhcLns/hOD0
6nKj+YBg6i/w/4TYyYRfQuQoqe2dBhfvcrO0PfPFUmGytmeyWNuYqe2ZKRY3
pml7pj3tlOYomgiHof3XVWcwbU17wwGg0R17Ohx/Fmu9ueAeFkhPzFIOy9T3
IGILnsCxeE3lhFrCxOGsfLykTMRMdkGR28hjDrLrBugRVDKR/sCL64UxJ2Ln
IRU+3qttDTh+mwLcoGj56DB3YvFA/vlBxcE31AUN67RhGMZWbjmtU1EXiOYd
dcEmTA5XBlnv37zb7oyQ6da0035PyVDUCrulQ/bUTHqDy37nGhVNoCk4mGCE
j22pPO8eoGGTpfkjE2DvoOIQ1G6qN0zdrNEKrVar9Feq/9mpnpoy1dPGVqoX
uEv8YfCg7oQD1mRBigbhC8CiKA6j2MV3wVvr0MIZ1B0k/G7FA4djegl4Vi9k
+QQvQmEbZM7JKJl7bJFAsnKWwBJ03zziBBN4dBZi0sHS4eFNdcJbq4DvTfqH
UvoPzeAmVl4Y9WZdNL9S+Hen8Jcz+CsJ/LX8/Vr6frIkD4UXsjf8/Oz9PyYq
ByVlDwAA
====
EOF
uudecode lapack-$LAPACK_VERSION.patch.gz.uue
gunzip lapack-$LAPACK_VERSION.patch.gz
rm -Rf lapack-$LAPACK_VERSION
tar -xf lapack-$LAPACK_VERSION.tar.gz
pushd lapack-$LAPACK_VERSION
patch -p1 < ../lapack-$LAPACK_VERSION.patch
cp make.inc.example make.inc
popd

# Create directories
mkdir -p lapack
pushd lapack
mkdir -p $CPU_TYPES

# Populate directories
for cpu_type in $CPU_TYPES ; do
  echo $cpu_type
  pushd $cpu_type
  cp -Rf ../../lapack-$LAPACK_VERSION .
  sed -i -e "s/march=$CPU_TYPE/march=$cpu_type/" lapack-$LAPACK_VERSION/make.inc
  popd
done

# Build in each directory
for cpu_type in $CPU_TYPES ; do
  echo $cpu_type ;
  pushd $cpu_type/lapack-$LAPACK_VERSION/BLAS/SRC ;
  make $MAKE_OPTS ;
  make $MAKE_OPTS libblas.so ;
  cp libblas.so ../.. ;
  popd ;
  pushd $cpu_type/lapack-$LAPACK_VERSION/SRC ;
  make $MAKE_OPTS ;
  make $MAKE_OPTS liblapack.so ;
  cp liblapack.so .. ;
  popd ;
done

# Done
popd
