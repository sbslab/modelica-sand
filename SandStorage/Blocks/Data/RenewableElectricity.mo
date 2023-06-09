within SandStorage.Blocks.Data;
record RenewableElectricity
  "Data model assuming 100% renewable on electricity supply with rEle=1"
  extends GenericSourceEnergy(
    final rBio=1.20,
    final rOth=1.05,
    final rCoa=1.05,
    final rChiWat=0.67,
    final rHotWat=1.73,
    final rSte=1.83,
    final rPro=1.15,
    final rOil=1.19,
    final rNatGas=1.09,
    rEle=1);
  annotation (Documentation(info="<html>
<h4>Source:</h4>
<p>
ASHRAE (2021). Standard Methods of Determining, Expressing, 
and Comparing Building Energy Performance and Greenhouse Gas Emissions.
ANSI/ASHRAE Standard 105-2021. 
</p>
<p>
Note: The primary source energy conversion factors are taken from Table K-2. 
Following the standard US and international government adoption practices, 
the adopted calculation method is the Captured Energy Efficiency Approach.
</p>
</html>", revisions="<html>
<ul>
<li>
January 10, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end RenewableElectricity;
