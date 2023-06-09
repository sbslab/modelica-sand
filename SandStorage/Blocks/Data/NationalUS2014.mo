within SandStorage.Blocks.Data;
record NationalUS2014
"US national-level data, 2014 ASHRAE Standard"
  extends GenericSourceEnergy(
    final rBio=1.05,
    final rOth=1.05,
    final rCoa=1.05,
    final rChiWat=1.04,
    final rHotWat=1.35,
    final rSte=1.45,
    final rPro=1.15,
    final rOil=1.19,
    final rNatGas=1.09,
    final rEle=3.15);
  annotation (Documentation(info="<html>
<h4>Source:</h4>
<p>Peterson, K., Torcellini, P., &amp; Grant, R. (2015). 
A Common Definition for Zero Energy Buildings. Retrieved from 
<a href=\"https://www.energy.gov/sites/prod/files/2015/09/f26/A%20Common%20Definition%20for%20Zero%20Energy%20Buildings.pdf\">
https://www.energy.gov/sites/prod/files/2015/09/f26/A Common Definition for Zero Energy Buildings.pdf</a> </p>
</html>", revisions="<html>
<ul>
<li>
January 10, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end NationalUS2014;
