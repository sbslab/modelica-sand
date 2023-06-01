within SandStorage.Blocks.Validation;
model ThermalDiscomfort
  "Example model to validate the thermal discomfort calculations"
  extends Modelica.Icons.Example;

  parameter Modelica.Units.SI.Area A=1
    "Total floor area of building";
  parameter SandStorage.Blocks.Data.NationalUS2021 rNat
    "Conversion factors r for US national level";
  parameter SandStorage.Blocks.Data.Regional2021.NWPP rNWPP
    "Conversion factors r for NWPP region";
  Modelica.Blocks.Sources.Constant TSetHea(k=273.15 + 20)
    "Heating temperature setpoint"
    annotation (Placement(transformation(extent={{-60,-10},{-40,10}})));
  Modelica.Blocks.Sources.Constant TSetCoo(k=273.15 + 25)
    "Cooling temperature setpoint"
    annotation (Placement(transformation(extent={{-60,-50},{-40,-30}})));
  SandStorage.Blocks.ThermalDiscomfort dis(n=1) "Discomfort"
    annotation (Placement(transformation(extent={{0,0},{20,20}})));
  Modelica.Blocks.Sources.Trapezoid TRoo(
    amplitude=9,
    rising(displayUnit="min") = 900,
    width(displayUnit="min") = 1800,
    falling(displayUnit="min") = 900,
    period(displayUnit="min") = 3600,
    offset=273.15 + 18,
    startTime(displayUnit="min") = 900) "Room temperature"
    annotation (Placement(transformation(extent={{-60,40},{-40,60}})));
equation
  connect(dis.TZon[1], TRoo.y) annotation (Line(points={{-2,16},{-32,16},{-32,50},
          {-39,50}}, color={0,0,127}));
  connect(dis.THeaLow[1], TSetHea.y) annotation (Line(points={{-2,10},{-34,10},{
          -34,0},{-39,0}}, color={0,0,127}));
  connect(TSetCoo.y, dis.TCooUpp[1]) annotation (Line(points={{-39,-40},{-20,-40},
          {-20,4},{-2,4}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false)),
    experiment(
      StopTime=3600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"),
      __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Blocks/Validation/ThermalDiscomfort.mos"
        "Simulate and plot"));
end ThermalDiscomfort;
