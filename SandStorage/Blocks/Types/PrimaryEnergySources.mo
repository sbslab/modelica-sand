within SandStorage.Blocks.Types;
type PrimaryEnergySources = enumeration(
    Solar "Solar",
    Hydro "Hydro",
    Nuclear "Nuclear",
    Wind "Wind",
    Geothermal "Geothermal",
    NaturalGas "Natural gas",
    Coal "Coal",
    Biomass "Biomass",
    Petroleum "Petroleum")
  "Enumeration of primary source energy types" annotation (Documentation(
      revisions="<html>
<ul>
<li>
January 10, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Data record with primary energy source types.
</p>
</html>"));
