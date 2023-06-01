within SandStorage.Blocks.Data.Regional2021;
record AZNM "Regional conversion factor for WECC Southwest"
  extends NationalUS2021(final rEle=2.87);
  annotation (Documentation(revisions="<html>
<ul>
<li>
January 10, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>Source energy conversion factors for the AZNM subregion (see map below). Map source: <a href=\"https://www.epa.gov/system/files/images/2022-01/egrid2020_subregion_map.png\">https://www.epa.gov/system/files/images/2022-01/egrid2020_subregion_map.png</a></p>
<p>
<img alt=\"image\"
src=\"modelica://SandStorage/Resources/Images/Blocks/Data/egrid2020_subregion_map.png\"
width=\"900\"
height=\"600\" /> 
</p>
<h4>Data source:</h4>
<p>ASHRAE (2021). Standard Methods of Determining, Expressing, and Comparing Building Energy Performance and Greenhouse Gas Emissions. ANSI/ASHRAE Standard 105-2021. </p>
<p>Note: The primary source energy conversion factors are taken from Table K-2. Following the standard US and international government adoption practices, the adopted calculation method is the Captured Energy Efficiency Approach. </p>
</html>"));
end AZNM;
