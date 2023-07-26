within SandStorage.Equipment.Examples;
model HeatExchangerAirWater
  "Subsystem testing model for the air-to-water heat exchanger"
  extends Modelica.Icons.Example;
  // Medium declarations
  package MediumWat = Modelica.Media.Water.StandardWater (
          p_default=963197,
          T_default=179+273.15,
          h_default=2776*1000);
  package MediumAir = Buildings.Media.Air;
      // Modelica.Media.Air.ReferenceAir.Air_pT
  // Nominal temperatures
  parameter Modelica.Units.SI.Temperature T_airIn_nominal = 675+273.15;
  parameter Modelica.Units.SI.Temperature T_airOut_nominal = 240+273.15;
  parameter Modelica.Units.SI.Temperature T_watIn_nominal = 170+273.15;
  parameter Modelica.Units.SI.Temperature T_watOut_nominal =  175+273.15;
  // Nominal pressures
  parameter Modelica.Units.SI.AbsolutePressure p_watOut_nominal = 963197;
  parameter Modelica.Units.SI.AbsolutePressure p_airOut_nominal = 200000;
  // Nominal mass flow rates
  parameter Modelica.Units.SI.MassFlowRate mWat_flow_nominal = 0.00191*3*1000;
  parameter Modelica.Units.SI.MassFlowRate mAir_flow_nominal = 20;
  // Nominal pressure drops
  parameter Modelica.Units.SI.PressureDifference dp_nominal = 6000;
  // Heat flow rate
  parameter Modelica.Units.SI.HeatFlowRate Q_flow_nominal = 8500;

  // Block instances
  Buildings.Fluid.Sources.MassFlowSource_T airIn(
    redeclare package Medium = MediumAir,
    T=T_airIn_nominal,
    use_m_flow_in=true,
    nPorts=1) "Inlet air volume"
    annotation (Placement(transformation(extent={{-50,-20},{-30,0}})));
  Buildings.Fluid.Sources.MassFlowSource_T watIn(
    redeclare package Medium = MediumWat,
    T=T_watIn_nominal,
    use_m_flow_in=true,
    use_T_in=false,
    nPorts=1) "Inlet water volume"
    annotation (Placement(transformation(extent={{60,40},{40,60}})));
  Buildings.Fluid.Sources.Boundary_pT watOut(
    redeclare package Medium = MediumWat,
    p=p_watOut_nominal,
    T=T_watOut_nominal,
    nPorts=1) "Outlet water volume" annotation (Placement(transformation(extent=
           {{-90,60},{-70,80}}, rotation=0.0)));
  Modelica.Blocks.Sources.RealExpression mWat_flow(y=mWat_flow_nominal)
    "Flow rate of water"
    annotation (Placement(transformation(extent={{90,48},{70,68}})));
  SandStorage.BaseClasses.Boundary_pT_highP airOut(
    redeclare package Medium = MediumAir,
    p=p_airOut_nominal,
    T=T_airOut_nominal,
    nPorts=1) "Outlet air volue"
    annotation (Placement(transformation(extent={{60,-20},{40,0}})));
  Buildings.Fluid.Sensors.SpecificEnthalpyTwoPort senSpeEnt(
    redeclare package Medium = MediumWat,
    m_flow_nominal=mWat_flow_nominal)
    "h sensor"
    annotation (Placement(transformation(extent={{-30,60},{-50,80}})));
  Modelica.Blocks.Sources.Ramp ramAir(
    height=-mAir_flow_nominal,
    duration=3600/3,
    offset=mAir_flow_nominal,
    startTime=3600/3) "Mass flow rate signal"
    annotation (Placement(transformation(extent={{-90,-12},{-70,8}})));
  SandStorage.Equipment.HeatExchanger hex(
    m1_flow_nominal=mWat_flow_nominal,
    m2_flow_nominal=mAir_flow_nominal,
    show_T=true,
    dp1_nominal=dp_nominal,
    dp2_nominal=dp_nominal,
    redeclare package MediumWat = MediumWat,
    redeclare package MediumAir = MediumAir) "Heat exchanger"
    annotation (Placement(transformation(extent={{10,0},{-10,20}})));
equation
  connect(watIn.m_flow_in, mWat_flow.y)
    annotation (Line(points={{62,58},{69,58}}, color={0,0,127}));
  connect(ramAir.y, airIn.m_flow_in)
    annotation (Line(points={{-69,-2},{-52,-2}}, color={0,0,127}));
  connect(airIn.ports[1], hex.port_a2) annotation (Line(points={{-30,-10},{-20,
          -10},{-20,4},{-10,4}}, color={0,127,255}));
  connect(hex.port_b2, airOut.ports[1]) annotation (Line(points={{10,4},{32,4},
          {32,-10},{40,-10}}, color={0,127,255}));
  connect(hex.port_a1, watIn.ports[1]) annotation (Line(points={{10,16},{24,16},
          {24,50},{40,50}}, color={0,127,255}));
  connect(watOut.ports[1], senSpeEnt.port_b)
    annotation (Line(points={{-70,70},{-70,70},{-50,70}}, color={0,127,255}));
  connect(senSpeEnt.port_a, hex.port_b1) annotation (Line(points={{-30,70},{-20,
          70},{-20,16},{-10,16}}, color={0,127,255}));
    annotation(Icon(coordinateSystem(preserveAspectRatio = false,extent = {{-100.0,-100.0},{100.0,100.0}})),
        experiment(
      StopTime=3600,
      Tolerance=1e-06,
      __Dymola_Algorithm="Cvode"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Equipment/Examples/HeatExchangerAirWater.mos"
        "Simulate and plot"),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>", info="<html>
<p>
Example model for the air-water heat exchanger.
</p>
</html>"));
end HeatExchangerAirWater;
