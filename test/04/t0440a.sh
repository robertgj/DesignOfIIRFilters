#!/bin/sh

prog=arcsn_test.m

depends="test/arcsn_test.m test_common.m arcsn.m carlson_RF.m"

tmp=/tmp/$$
here=`pwd`
if [ $? -ne 0 ]; then echo "Failed pwd"; exit 1; fi

fail()
{
        echo FAILED ${0#$here"/"} $prog 1>&2
        cd $here
        rm -rf $tmp
        exit 1
}

pass()
{
        echo PASSED ${0#$here"/"} $prog
        cd $here
        rm -rf $tmp
        exit 0
}

trap "fail" 1 2 3 15
mkdir $tmp
if [ $? -ne 0 ]; then echo "Failed mkdir"; exit 1; fi
for file in $depends;do \
  cp -R src/$file $tmp; \
  if [ $? -ne 0 ]; then echo "Failed cp "$file; fail; fi \
done
cd $tmp
if [ $? -ne 0 ]; then echo "Failed cd"; fail; fi

#
# the output should look like this
#
cat > test.ok << 'EOF'
warning: Adjusting real k=0.05,uasn(12,4)= 1.5255249+ 1.1755705j
warning: Adjusting real k=0.05,uasn(9,5)= 1.5267628+ 0.5253289j
warning: Adjusting real k=0.05,uasn(10,5)= 1.4316572+ 0.5562306j
warning: Adjusting real k=0.05,uasn(11,5)= 1.3365515+ 0.5871323j
warning: Adjusting real k=0.05,uasn(12,5)= 1.2414459+ 0.6180340j
warning: Adjusting real k=0.05,uasn(8,6)= 1.5435589+ 0.0000000j
warning: Adjusting real k=0.05,uasn(9,6)= 1.4435589+ 0.0000000j
warning: Adjusting real k=0.05,uasn(10,6)= 1.3435589+ 0.0000000j
warning: Adjusting real k=0.05,uasn(11,6)= 1.2435589+ 0.0000000j
warning: Adjusting real k=0.05,uasn(12,6)= 1.1435589+ 0.0000000j
warning: Adjusting real k=0.05,uasn(9,7)= 1.5267628+-0.5253289j
warning: Adjusting real k=0.05,uasn(10,7)= 1.4316572+-0.5562306j
warning: Adjusting real k=0.05,uasn(11,7)= 1.3365515+-0.5871323j
warning: Adjusting real k=0.05,uasn(12,7)= 1.2414459+-0.6180340j
warning: Adjusting real k=0.05,uasn(12,8)= 1.5255249+-1.1755705j
warning: Conjugating k=0.05,adj_uasn(12,4)= 1.6180340+ 1.1755705j
warning: Conjugating k=0.05,adj_uasn(9,5)= 1.6167961+ 0.5253289j
warning: Conjugating k=0.05,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.05,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.05,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.05,adj_uasn(9,7)= 1.6167961+-0.5253289j
warning: Conjugating k=0.05,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.05,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.05,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Conjugating k=0.05,adj_uasn(12,8)= 1.6180340+-1.1755705j
warning: Adjusting real k=0.10,uasn(12,4)= 1.5314571+ 1.1755705j
warning: Adjusting real k=0.10,uasn(9,5)= 1.5326950+ 0.5253289j
warning: Adjusting real k=0.10,uasn(10,5)= 1.4375894+ 0.5562306j
warning: Adjusting real k=0.10,uasn(11,5)= 1.3424837+ 0.5871323j
warning: Adjusting real k=0.10,uasn(12,5)= 1.2473781+ 0.6180340j
warning: Adjusting real k=0.10,uasn(8,6)= 1.5494911+ 0.0000000j
warning: Adjusting real k=0.10,uasn(9,6)= 1.4494911+ 0.0000000j
warning: Adjusting real k=0.10,uasn(10,6)= 1.3494911+ 0.0000000j
warning: Adjusting real k=0.10,uasn(11,6)= 1.2494911+ 0.0000000j
warning: Adjusting real k=0.10,uasn(12,6)= 1.1494911+ 0.0000000j
warning: Adjusting real k=0.10,uasn(9,7)= 1.5326950+-0.5253289j
warning: Adjusting real k=0.10,uasn(10,7)= 1.4375894+-0.5562306j
warning: Adjusting real k=0.10,uasn(11,7)= 1.3424837+-0.5871323j
warning: Adjusting real k=0.10,uasn(12,7)= 1.2473781+-0.6180340j
warning: Adjusting real k=0.10,uasn(12,8)= 1.5314571+-1.1755705j
warning: Conjugating k=0.10,adj_uasn(12,4)= 1.6180340+ 1.1755705j
warning: Conjugating k=0.10,adj_uasn(9,5)= 1.6167961+ 0.5253289j
warning: Conjugating k=0.10,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.10,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.10,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.10,adj_uasn(9,7)= 1.6167961+-0.5253289j
warning: Conjugating k=0.10,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.10,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.10,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Conjugating k=0.10,adj_uasn(12,8)= 1.6180340+-1.1755705j
warning: Adjusting real k=0.15,uasn(12,4)= 1.5414573+ 1.1755705j
warning: Adjusting real k=0.15,uasn(9,5)= 1.5426952+ 0.5253289j
warning: Adjusting real k=0.15,uasn(10,5)= 1.4475896+ 0.5562306j
warning: Adjusting real k=0.15,uasn(11,5)= 1.3524839+ 0.5871323j
warning: Adjusting real k=0.15,uasn(12,5)= 1.2573783+ 0.6180340j
warning: Adjusting real k=0.15,uasn(8,6)= 1.5594913+ 0.0000000j
warning: Adjusting real k=0.15,uasn(9,6)= 1.4594913+ 0.0000000j
warning: Adjusting real k=0.15,uasn(10,6)= 1.3594913+ 0.0000000j
warning: Adjusting real k=0.15,uasn(11,6)= 1.2594913+ 0.0000000j
warning: Adjusting real k=0.15,uasn(12,6)= 1.1594913+ 0.0000000j
warning: Adjusting real k=0.15,uasn(9,7)= 1.5426952+-0.5253289j
warning: Adjusting real k=0.15,uasn(10,7)= 1.4475896+-0.5562306j
warning: Adjusting real k=0.15,uasn(11,7)= 1.3524839+-0.5871323j
warning: Adjusting real k=0.15,uasn(12,7)= 1.2573783+-0.6180340j
warning: Adjusting real k=0.15,uasn(12,8)= 1.5414573+-1.1755705j
warning: Conjugating k=0.15,adj_uasn(12,4)= 1.6180340+ 1.1755705j
warning: Conjugating k=0.15,adj_uasn(9,5)= 1.6167961+ 0.5253289j
warning: Conjugating k=0.15,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.15,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.15,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.15,adj_uasn(9,7)= 1.6167961+-0.5253289j
warning: Conjugating k=0.15,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.15,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.15,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Conjugating k=0.15,adj_uasn(12,8)= 1.6180340+-1.1755705j
warning: Adjusting real k=0.20,uasn(12,4)= 1.5557017+ 1.1755705j
warning: Adjusting real k=0.20,uasn(9,5)= 1.5569396+ 0.5253289j
warning: Adjusting real k=0.20,uasn(10,5)= 1.4618340+ 0.5562306j
warning: Adjusting real k=0.20,uasn(11,5)= 1.3667283+ 0.5871323j
warning: Adjusting real k=0.20,uasn(12,5)= 1.2716227+ 0.6180340j
warning: Adjusting real k=0.20,uasn(8,6)= 1.5737357+ 0.0000000j
warning: Adjusting real k=0.20,uasn(9,6)= 1.4737357+ 0.0000000j
warning: Adjusting real k=0.20,uasn(10,6)= 1.3737357+ 0.0000000j
warning: Adjusting real k=0.20,uasn(11,6)= 1.2737357+ 0.0000000j
warning: Adjusting real k=0.20,uasn(12,6)= 1.1737357+ 0.0000000j
warning: Adjusting real k=0.20,uasn(9,7)= 1.5569396+-0.5253289j
warning: Adjusting real k=0.20,uasn(10,7)= 1.4618340+-0.5562306j
warning: Adjusting real k=0.20,uasn(11,7)= 1.3667283+-0.5871323j
warning: Adjusting real k=0.20,uasn(12,7)= 1.2716227+-0.6180340j
warning: Adjusting real k=0.20,uasn(12,8)= 1.5557017+-1.1755705j
warning: Conjugating k=0.20,adj_uasn(12,4)= 1.6180340+ 1.1755705j
warning: Conjugating k=0.20,adj_uasn(9,5)= 1.6167961+ 0.5253289j
warning: Conjugating k=0.20,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.20,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.20,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.20,adj_uasn(9,7)= 1.6167961+-0.5253289j
warning: Conjugating k=0.20,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.20,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.20,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Conjugating k=0.20,adj_uasn(12,8)= 1.6180340+-1.1755705j
warning: Adjusting real k=0.25,uasn(12,4)= 1.5744505+ 1.1755705j
warning: Adjusting real k=0.25,uasn(9,5)= 1.5756884+ 0.5253289j
warning: Adjusting real k=0.25,uasn(10,5)= 1.4805827+ 0.5562306j
warning: Adjusting real k=0.25,uasn(11,5)= 1.3854771+ 0.5871323j
warning: Adjusting real k=0.25,uasn(12,5)= 1.2903714+ 0.6180340j
warning: Adjusting real k=0.25,uasn(8,6)= 1.5924844+ 0.0000000j
warning: Adjusting real k=0.25,uasn(9,6)= 1.4924844+ 0.0000000j
warning: Adjusting real k=0.25,uasn(10,6)= 1.3924844+ 0.0000000j
warning: Adjusting real k=0.25,uasn(11,6)= 1.2924844+ 0.0000000j
warning: Adjusting real k=0.25,uasn(12,6)= 1.1924844+ 0.0000000j
warning: Adjusting real k=0.25,uasn(9,7)= 1.5756884+-0.5253289j
warning: Adjusting real k=0.25,uasn(10,7)= 1.4805827+-0.5562306j
warning: Adjusting real k=0.25,uasn(11,7)= 1.3854771+-0.5871323j
warning: Adjusting real k=0.25,uasn(12,7)= 1.2903714+-0.6180340j
warning: Adjusting real k=0.25,uasn(12,8)= 1.5744505+-1.1755705j
warning: Conjugating k=0.25,adj_uasn(12,4)= 1.6180340+ 1.1755705j
warning: Conjugating k=0.25,adj_uasn(9,5)= 1.6167961+ 0.5253289j
warning: Conjugating k=0.25,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.25,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.25,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.25,adj_uasn(9,7)= 1.6167961+-0.5253289j
warning: Conjugating k=0.25,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.25,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.25,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Conjugating k=0.25,adj_uasn(12,8)= 1.6180340+-1.1755705j
warning: Adjusting real k=0.30,uasn(12,4)= 1.5980633+ 1.1755705j
warning: Adjusting real k=0.30,uasn(9,5)= 1.5993012+ 0.5253289j
warning: Adjusting real k=0.30,uasn(10,5)= 1.5041955+ 0.5562306j
warning: Adjusting real k=0.30,uasn(11,5)= 1.4090899+ 0.5871323j
warning: Adjusting real k=0.30,uasn(12,5)= 1.3139842+ 0.6180340j
warning: Adjusting real k=0.30,uasn(9,6)= 1.5160972+ 0.0000000j
warning: Adjusting real k=0.30,uasn(10,6)= 1.4160972+ 0.0000000j
warning: Adjusting real k=0.30,uasn(11,6)= 1.3160972+ 0.0000000j
warning: Adjusting real k=0.30,uasn(12,6)= 1.2160972+ 0.0000000j
warning: Adjusting real k=0.30,uasn(9,7)= 1.5993012+-0.5253289j
warning: Adjusting real k=0.30,uasn(10,7)= 1.5041955+-0.5562306j
warning: Adjusting real k=0.30,uasn(11,7)= 1.4090899+-0.5871323j
warning: Adjusting real k=0.30,uasn(12,7)= 1.3139842+-0.6180340j
warning: Adjusting real k=0.30,uasn(12,8)= 1.5980633+-1.1755705j
warning: Conjugating k=0.30,adj_uasn(12,4)= 1.6180340+ 1.1755705j
warning: Conjugating k=0.30,adj_uasn(9,5)= 1.6167961+ 0.5253289j
warning: Conjugating k=0.30,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.30,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.30,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.30,adj_uasn(9,7)= 1.6167961+-0.5253289j
warning: Conjugating k=0.30,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.30,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.30,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Conjugating k=0.30,adj_uasn(12,8)= 1.6180340+-1.1755705j
warning: Adjusting real k=0.35,uasn(10,5)= 1.5331545+ 0.5562306j
warning: Adjusting real k=0.35,uasn(11,5)= 1.4380488+ 0.5871323j
warning: Adjusting real k=0.35,uasn(12,5)= 1.3429432+ 0.6180340j
warning: Adjusting real k=0.35,uasn(9,6)= 1.5450562+ 0.0000000j
warning: Adjusting real k=0.35,uasn(10,6)= 1.4450562+ 0.0000000j
warning: Adjusting real k=0.35,uasn(11,6)= 1.3450562+ 0.0000000j
warning: Adjusting real k=0.35,uasn(12,6)= 1.2450562+ 0.0000000j
warning: Adjusting real k=0.35,uasn(10,7)= 1.5331545+-0.5562306j
warning: Adjusting real k=0.35,uasn(11,7)= 1.4380488+-0.5871323j
warning: Adjusting real k=0.35,uasn(12,7)= 1.3429432+-0.6180340j
warning: Conjugating k=0.35,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.35,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.35,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.35,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.35,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.35,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Adjusting real k=0.40,uasn(10,5)= 1.5680980+ 0.5562306j
warning: Adjusting real k=0.40,uasn(11,5)= 1.4729924+ 0.5871323j
warning: Adjusting real k=0.40,uasn(12,5)= 1.3778867+ 0.6180340j
warning: Adjusting real k=0.40,uasn(9,6)= 1.5799997+ 0.0000000j
warning: Adjusting real k=0.40,uasn(10,6)= 1.4799997+ 0.0000000j
warning: Adjusting real k=0.40,uasn(11,6)= 1.3799997+ 0.0000000j
warning: Adjusting real k=0.40,uasn(12,6)= 1.2799997+ 0.0000000j
warning: Adjusting real k=0.40,uasn(10,7)= 1.5680980+-0.5562306j
warning: Adjusting real k=0.40,uasn(11,7)= 1.4729924+-0.5871323j
warning: Adjusting real k=0.40,uasn(12,7)= 1.3778867+-0.6180340j
warning: Conjugating k=0.40,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.40,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.40,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.40,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.40,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.40,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Adjusting real k=0.45,uasn(10,5)= 1.6098707+ 0.5562306j
warning: Adjusting real k=0.45,uasn(11,5)= 1.5147651+ 0.5871323j
warning: Adjusting real k=0.45,uasn(12,5)= 1.4196594+ 0.6180340j
warning: Adjusting real k=0.45,uasn(9,6)= 1.6217725+ 0.0000000j
warning: Adjusting real k=0.45,uasn(10,6)= 1.5217725+ 0.0000000j
warning: Adjusting real k=0.45,uasn(11,6)= 1.4217725+ 0.0000000j
warning: Adjusting real k=0.45,uasn(12,6)= 1.3217725+ 0.0000000j
warning: Adjusting real k=0.45,uasn(10,7)= 1.6098707+-0.5562306j
warning: Adjusting real k=0.45,uasn(11,7)= 1.5147651+-0.5871323j
warning: Adjusting real k=0.45,uasn(12,7)= 1.4196594+-0.6180340j
warning: Conjugating k=0.45,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.45,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.45,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.45,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.45,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.45,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Adjusting real k=0.50,uasn(10,5)= 1.6595990+ 0.5562306j
warning: Adjusting real k=0.50,uasn(11,5)= 1.5644933+ 0.5871323j
warning: Adjusting real k=0.50,uasn(12,5)= 1.4693877+ 0.6180340j
warning: Adjusting real k=0.50,uasn(9,6)= 1.6715007+ 0.0000000j
warning: Adjusting real k=0.50,uasn(10,6)= 1.5715007+ 0.0000000j
warning: Adjusting real k=0.50,uasn(11,6)= 1.4715007+ 0.0000000j
warning: Adjusting real k=0.50,uasn(12,6)= 1.3715007+ 0.0000000j
warning: Adjusting real k=0.50,uasn(10,7)= 1.6595990+-0.5562306j
warning: Adjusting real k=0.50,uasn(11,7)= 1.5644933+-0.5871323j
warning: Adjusting real k=0.50,uasn(12,7)= 1.4693877+-0.6180340j
warning: Conjugating k=0.50,adj_uasn(10,5)= 1.7119017+ 0.5562306j
warning: Conjugating k=0.50,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.50,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.50,adj_uasn(10,7)= 1.7119017+-0.5562306j
warning: Conjugating k=0.50,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.50,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Adjusting real k=0.55,uasn(11,5)= 1.6237016+ 0.5871323j
warning: Adjusting real k=0.55,uasn(12,5)= 1.5285960+ 0.6180340j
warning: Adjusting real k=0.55,uasn(10,6)= 1.6307090+ 0.0000000j
warning: Adjusting real k=0.55,uasn(11,6)= 1.5307090+ 0.0000000j
warning: Adjusting real k=0.55,uasn(12,6)= 1.4307090+ 0.0000000j
warning: Adjusting real k=0.55,uasn(11,7)= 1.6237016+-0.5871323j
warning: Adjusting real k=0.55,uasn(12,7)= 1.5285960+-0.6180340j
warning: Conjugating k=0.55,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.55,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.55,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.55,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Adjusting real k=0.60,uasn(11,5)= 1.6945002+ 0.5871323j
warning: Adjusting real k=0.60,uasn(12,5)= 1.5993946+ 0.6180340j
warning: Adjusting real k=0.60,uasn(10,6)= 1.7015076+ 0.0000000j
warning: Adjusting real k=0.60,uasn(11,6)= 1.6015076+ 0.0000000j
warning: Adjusting real k=0.60,uasn(12,6)= 1.5015076+ 0.0000000j
warning: Adjusting real k=0.60,uasn(11,7)= 1.6945002+-0.5871323j
warning: Adjusting real k=0.60,uasn(12,7)= 1.5993946+-0.6180340j
warning: Adjusting imag. k=0.60,adj_uasn(12,1)= 0.0000000+ 1.9906056j
warning: Conjugating k=0.60,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.60,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.60,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.60,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Adjusting imag. k=0.60,adj_uasn(12,11)= 0.0000000+-1.9906056j
warning: Adjusting real k=0.65,uasn(11,5)= 1.7799008+ 0.5871323j
warning: Adjusting real k=0.65,uasn(12,5)= 1.6847952+ 0.6180340j
warning: Adjusting real k=0.65,uasn(10,6)= 1.7869082+ 0.0000000j
warning: Adjusting real k=0.65,uasn(11,6)= 1.6869082+ 0.0000000j
warning: Adjusting real k=0.65,uasn(12,6)= 1.5869082+ 0.0000000j
warning: Adjusting real k=0.65,uasn(11,7)= 1.7799008+-0.5871323j
warning: Adjusting real k=0.65,uasn(12,7)= 1.6847952+-0.6180340j
warning: Adjusting imag. k=0.65,adj_uasn(12,1)= 0.0000000+ 1.8519459j
warning: Conjugating k=0.65,adj_uasn(11,5)= 1.8070074+ 0.5871323j
warning: Conjugating k=0.65,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.65,adj_uasn(11,7)= 1.8070074+-0.5871323j
warning: Conjugating k=0.65,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Adjusting imag. k=0.65,adj_uasn(12,11)= 0.0000000+-1.8519459j
warning: Adjusting real k=0.70,uasn(12,5)= 1.7892750+ 0.6180340j
warning: Adjusting real k=0.70,uasn(11,6)= 1.7913880+ 0.0000000j
warning: Adjusting real k=0.70,uasn(12,6)= 1.6913880+ 0.0000000j
warning: Adjusting real k=0.70,uasn(12,7)= 1.7892750+-0.6180340j
warning: Adjusting imag. k=0.70,adj_uasn(11,1)= 0.0000000+ 1.8252816j
warning: Adjusting imag. k=0.70,adj_uasn(12,1)= 0.0000000+ 1.7252816j
warning: Adjusting imag. k=0.70,adj_uasn(12,2)= 0.6180340+ 1.8231686j
warning: Conjugating k=0.70,adj_uasn(12,5)= 1.9021130+ 0.6180340j
warning: Conjugating k=0.70,adj_uasn(12,7)= 1.9021130+-0.6180340j
warning: Adjusting imag. k=0.70,adj_uasn(12,10)= 0.6180340+-1.8231686j
warning: Adjusting imag. k=0.70,adj_uasn(11,11)= 0.0000000+-1.8252816j
warning: Adjusting imag. k=0.70,adj_uasn(12,11)= 0.0000000+-1.7252816j
warning: Adjusting real k=0.75,uasn(12,6)= 1.8219796+ 0.0000000j
warning: Adjusting imag. k=0.75,adj_uasn(11,1)= 0.0000000+ 1.7089232j
warning: Adjusting imag. k=0.75,adj_uasn(12,1)= 0.0000000+ 1.6089232j
warning: Adjusting imag. k=0.75,adj_uasn(11,2)= 0.5871323+ 1.8019159j
warning: Adjusting imag. k=0.75,adj_uasn(12,2)= 0.6180340+ 1.7068102j
warning: Adjusting imag. k=0.75,adj_uasn(11,10)= 0.5871323+-1.8019159j
warning: Adjusting imag. k=0.75,adj_uasn(12,10)= 0.6180340+-1.7068102j
warning: Adjusting imag. k=0.75,adj_uasn(11,11)= 0.0000000+-1.7089232j
warning: Adjusting imag. k=0.75,adj_uasn(12,11)= 0.0000000+-1.6089232j
warning: Adjusting real k=0.80,uasn(12,6)= 1.9906056+ 0.0000000j
warning: Adjusting imag. k=0.80,adj_uasn(10,1)= 0.0000000+ 1.7015076j
warning: Adjusting imag. k=0.80,adj_uasn(11,1)= 0.0000000+ 1.6015076j
warning: Adjusting imag. k=0.80,adj_uasn(12,1)= 0.0000000+ 1.5015076j
warning: Adjusting imag. k=0.80,adj_uasn(11,2)= 0.5871323+ 1.6945002j
warning: Adjusting imag. k=0.80,adj_uasn(12,2)= 0.6180340+ 1.5993946j
warning: Adjusting imag. k=0.80,adj_uasn(11,10)= 0.5871323+-1.6945002j
warning: Adjusting imag. k=0.80,adj_uasn(12,10)= 0.6180340+-1.5993946j
warning: Adjusting imag. k=0.80,adj_uasn(10,11)= 0.0000000+-1.7015076j
warning: Adjusting imag. k=0.80,adj_uasn(11,11)= 0.0000000+-1.6015076j
warning: Adjusting imag. k=0.80,adj_uasn(12,11)= 0.0000000+-1.5015076j
warning: Adjusting imag. k=0.85,adj_uasn(10,1)= 0.0000000+ 1.6019191j
warning: Adjusting imag. k=0.85,adj_uasn(11,1)= 0.0000000+ 1.5019191j
warning: Adjusting imag. k=0.85,adj_uasn(12,1)= 0.0000000+ 1.4019191j
warning: Adjusting imag. k=0.85,adj_uasn(10,2)= 0.5562306+ 1.6900174j
warning: Adjusting imag. k=0.85,adj_uasn(11,2)= 0.5871323+ 1.5949117j
warning: Adjusting imag. k=0.85,adj_uasn(12,2)= 0.6180340+ 1.4998061j
warning: Adjusting imag. k=0.85,adj_uasn(10,10)= 0.5562306+-1.6900174j
warning: Adjusting imag. k=0.85,adj_uasn(11,10)= 0.5871323+-1.5949117j
warning: Adjusting imag. k=0.85,adj_uasn(12,10)= 0.6180340+-1.4998061j
warning: Adjusting imag. k=0.85,adj_uasn(10,11)= 0.0000000+-1.6019191j
warning: Adjusting imag. k=0.85,adj_uasn(11,11)= 0.0000000+-1.5019191j
warning: Adjusting imag. k=0.85,adj_uasn(12,11)= 0.0000000+-1.4019191j
warning: Adjusting imag. k=0.90,adj_uasn(9,1)= 0.0000000+ 1.6092333j
warning: Adjusting imag. k=0.90,adj_uasn(10,1)= 0.0000000+ 1.5092333j
warning: Adjusting imag. k=0.90,adj_uasn(11,1)= 0.0000000+ 1.4092333j
warning: Adjusting imag. k=0.90,adj_uasn(12,1)= 0.0000000+ 1.3092333j
warning: Adjusting imag. k=0.90,adj_uasn(10,2)= 0.5562306+ 1.5973316j
warning: Adjusting imag. k=0.90,adj_uasn(11,2)= 0.5871323+ 1.5022260j
warning: Adjusting imag. k=0.90,adj_uasn(12,2)= 0.6180340+ 1.4071203j
warning: Adjusting imag. k=0.90,adj_uasn(10,10)= 0.5562306+-1.5973316j
warning: Adjusting imag. k=0.90,adj_uasn(11,10)= 0.5871323+-1.5022260j
warning: Adjusting imag. k=0.90,adj_uasn(12,10)= 0.6180340+-1.4071203j
warning: Adjusting imag. k=0.90,adj_uasn(9,11)= 0.0000000+-1.6092333j
warning: Adjusting imag. k=0.90,adj_uasn(10,11)= 0.0000000+-1.5092333j
warning: Adjusting imag. k=0.90,adj_uasn(11,11)= 0.0000000+-1.4092333j
warning: Adjusting imag. k=0.90,adj_uasn(12,11)= 0.0000000+-1.3092333j
warning: Adjusting imag. k=0.95,adj_uasn(9,1)= 0.0000000+ 1.5226761j
warning: Adjusting imag. k=0.95,adj_uasn(10,1)= 0.0000000+ 1.4226761j
warning: Adjusting imag. k=0.95,adj_uasn(11,1)= 0.0000000+ 1.3226761j
warning: Adjusting imag. k=0.95,adj_uasn(12,1)= 0.0000000+ 1.2226761j
warning: Adjusting imag. k=0.95,adj_uasn(9,2)= 0.5253289+ 1.6058800j
warning: Adjusting imag. k=0.95,adj_uasn(10,2)= 0.5562306+ 1.5107744j
warning: Adjusting imag. k=0.95,adj_uasn(11,2)= 0.5871323+ 1.4156687j
warning: Adjusting imag. k=0.95,adj_uasn(12,2)= 0.6180340+ 1.3205631j
warning: Adjusting imag. k=0.95,adj_uasn(12,3)= 1.1755705+ 1.6046421j
warning: Adjusting imag. k=0.95,adj_uasn(12,9)= 1.1755705+-1.6046421j
warning: Adjusting imag. k=0.95,adj_uasn(9,10)= 0.5253289+-1.6058800j
warning: Adjusting imag. k=0.95,adj_uasn(10,10)= 0.5562306+-1.5107744j
warning: Adjusting imag. k=0.95,adj_uasn(11,10)= 0.5871323+-1.4156687j
warning: Adjusting imag. k=0.95,adj_uasn(12,10)= 0.6180340+-1.3205631j
warning: Adjusting imag. k=0.95,adj_uasn(9,11)= 0.0000000+-1.5226761j
warning: Adjusting imag. k=0.95,adj_uasn(10,11)= 0.0000000+-1.4226761j
warning: Adjusting imag. k=0.95,adj_uasn(11,11)= 0.0000000+-1.3226761j
warning: Adjusting imag. k=0.95,adj_uasn(12,11)= 0.0000000+-1.2226761j
EOF
if [ $? -ne 0 ]; then echo "Failed output cat"; fail; fi

#
# run and see if the results match
#
echo "Running $prog"
octave --no-gui -q $prog >test.out 2>&1
if [ $? -ne 0 ]; then echo "Failed running $prog"; fail; fi

diff -Bb test.ok test.out
if [ $? -ne 0 ]; then echo "Failed diff -Bb"; fail; fi

#
# this much worked
#
pass

