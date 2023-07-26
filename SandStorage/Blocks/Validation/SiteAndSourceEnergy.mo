within SandStorage.Blocks.Validation;
model SiteAndSourceEnergy
  "Example model to validate the site and source energy calculations"
  extends Modelica.Icons.Example;

  parameter Modelica.Units.SI.Area A=1
    "Total floor area of building";
  parameter SandStorage.Blocks.Data.NationalUS2021 rNat
    "Conversion factors r for US national level";
  parameter SandStorage.Blocks.Data.Regional2021.NWPP rNWPP
    "Conversion factors r for NWPP region";
  Modelica.Blocks.Sources.Constant PEle(k=1000) "Electric power [Ws]"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  SandStorage.Blocks.SiteEnergy ESit(n=2, A=A) "Site energy"
    annotation (Placement(transformation(extent={{0,-50},{20,-30}})));
  SandStorage.Blocks.SourceEnergy ESouUSA(
    n=2,
    A=A,
    conFac=rNat) "Source energy - National"
    annotation (Placement(transformation(extent={{0,10},{20,30}})));
  Modelica.Blocks.Sources.Constant QFloNatGas(k=500) "Natural gas energy"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  Modelica.Blocks.Sources.IntegerConstant eneTyp[2](k={1,2}) "Energy types"
    annotation (Placement(transformation(extent={{-60,29},{-40,51}})));
  SandStorage.Blocks.SourceEnergy ESouNWPP(
    n=2,
    A=A,
    conFac=rNWPP) "Source energy - NWPP region"
    annotation (Placement(transformation(extent={{0,60},{20,80}})));
equation
  connect(PEle.y, ESit.P[1]) annotation (Line(points={{-39,0},{-20,0},{-20,-40},
          {-2,-40},{-2,-41}}, color={0,0,127}));
  connect(QFloNatGas.y, ESit.P[2])
    annotation (Line(points={{-39,-40},{-2,-40},{-2,-39}}, color={0,0,127}));
  connect(eneTyp.y, ESouUSA.typSou) annotation (Line(points={{-39,40},{-30,40},{
          -30,26},{-2,26}}, color={255,127,0}));
  connect(PEle.y, ESouUSA.PSit[1]) annotation (Line(points={{-39,0},{-20,0},{-20,
          20},{-4,20},{-4,19},{-2,19}}, color={0,0,127}));
  connect(QFloNatGas.y, ESouUSA.PSit[2]) annotation (Line(points={{-39,-40},{-20,
          -40},{-20,21},{-2,21}}, color={0,0,127}));
  connect(eneTyp.y, ESouNWPP.typSou) annotation (Line(points={{-39,40},{-30,40},
          {-30,76},{-2,76}}, color={255,127,0}));
  connect(PEle.y, ESouNWPP.PSit[1]) annotation (Line(points={{-39,0},{-20,0},{-20,
          69},{-2,69}}, color={0,0,127}));
  connect(QFloNatGas.y, ESouNWPP.PSit[2]) annotation (Line(points={{-39,-40},{-20,
          -40},{-20,71},{-2,71}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=3600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"),
      __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Blocks/Validation/SiteAndSourceEnergy.mos"
        "Simulate and plot"),
    Documentation(revisions="<html>
<ul>
<li>
January 10, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Example model to test the site and source energy blocks.
</p>
</html>"));
end SiteAndSourceEnergy;
