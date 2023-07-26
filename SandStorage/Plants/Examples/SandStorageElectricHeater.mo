within SandStorage.Plants.Examples;
model SandStorageElectricHeater
  "Steam plant with sand TES and an electric heaterMain model for the plant simulation"
  extends Modelica.Icons.Example;
  package MediumWat = Modelica.Media.Water.StandardWater (
            p_default=963197,
            T_default=180+273.15);
  parameter Modelica.Units.SI.MassFlowRate mWat_flow_nominal = 1.7;
  parameter Modelica.Units.SI.Temperature TWatIn_nominal = 170+273.15;
  parameter Modelica.Units.SI.Temperature TWatOut_nominal =  180+273.15;
  parameter Modelica.Units.SI.AbsolutePressure pSte_nominal = 963197;
  parameter Modelica.Units.SI.Voltage V_nominal=480 "Nominal grid voltage";
  parameter Modelica.Units.SI.Power PWin=2e6
    "Nominal power of the wind turbine";
  parameter Modelica.Units.SI.Power PSun=2e6
    "Nominal power of the PV";
  parameter Modelica.Units.SI.DensityOfHeatFlowRate W_m2_nominal=1000
    "Nominal solar power per unit area";
  parameter Real eff_PV = 0.12*0.85*0.9
    "Nominal solar power conversion efficiency (this should consider converion efficiency, area covered, AC/DC losses)";
  parameter Modelica.Units.SI.Area A_PV=PSun/eff_PV/W_m2_nominal
    "Nominal area of a P installation";
  parameter String filNam=
    "modelica://SandStorage/Resources/Data/Plants/Examples/DailyHeatingProfile.mos"
    "File name with thermal loads as time series";
  parameter Modelica.Units.SI.Area A=1
    "Total floor area of building";
  parameter SandStorage.Blocks.Data.NationalUS2021 rNat
    "Conversion factors r for US national level";
  SandStorage.Plants.SandStorageElectricHeater pla "Plant"
    annotation (Placement(transformation(extent={{40,-60},{60,-40}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.PVSimpleOriented pv1(
    eta_DCAC=0.89,
    A=A_PV,
    fAct=0.9,
    eta=0.12,
    linearized=false,
    V_nominal=V_nominal,
    pf=0.85,
    azi=Buildings.Types.Azimuth.S,
    til=0.5235987755983) "PV"
    annotation (Placement(transformation(extent={{-30,-20},{-10,0}})));
  Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather data bus"
    annotation (Placement(transformation(extent={{-30,60},{-10,80}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.WindTurbine winTur(
    V_nominal=V_nominal,
    h=15,
    hRef=10,
    pf=0.94,
    eta_DCAC=0.92,
    nWin=0.4,
    tableOnFile=false,
    scale=PWin) "Wind turbine model"
    annotation (Placement(transformation(extent={{-30,10},{-10,30}})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
    computeWetBulbTemperature=false,
    filNam=Modelica.Utilities.Files.loadResource(
        "modelica://SandStorage/Resources/weatherdata/Denver.mos"))
    "Weather data model"
    annotation (Placement(transformation(extent={{-80,60},{-60,80}})));
  Modelica.Blocks.Math.Add PRen(
    y(unit="W")) "Renewable power on site"
    annotation (Placement(transformation(extent={{10,0},{30,20}})));
    Buildings.Fluid.Sources.Boundary_pT watOut(
    redeclare package Medium = MediumWat,
    p=pSte_nominal,
    nPorts=1) "Outlet water volume" annotation (Placement(transformation(extent={{-20,-90},
            {0,-70}},           rotation=0.0)));
    Buildings.Fluid.Sources.MassFlowSource_T watIn(
    redeclare package Medium = MediumWat,
    m_flow=mWat_flow_nominal,
    T=TWatIn_nominal,
    use_m_flow_in=true,
    use_T_in=false,
    nPorts=1) "Inlet water volume"
    annotation (Placement(transformation(extent={{-20,-60},{0,-40}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.Grid gri(f=60,
    V=V_nominal)
    "Grid model that provides power to the system"
    annotation (Placement(transformation(extent={{-80,30},{-60,50}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive loa(
    mode=Buildings.Electrical.Types.Load.VariableZ_P_input,
    V_nominal=V_nominal,
    linearized=false,
    use_pf_in=false,
    pf=1)
    "Electrical load of the plant"
    annotation (Placement(transformation(extent={{-60,-40},{-40,-20}})));
  Modelica.Blocks.Sources.CombiTimeTable disDat(
    tableOnFile=true,
    tableName="tab1",
    fileName=Modelica.Utilities.Files.loadResource(filNam),
    extrapolation=Modelica.Blocks.Types.Extrapolation.Periodic,
    y(unit={"kg/s"}),
    offset={0},
    columns={2},
    smoothness=Modelica.Blocks.Types.Smoothness.MonotoneContinuousDerivative1)
    "Data reader for steam loads at district level (y[1] is mass flow rate, y[2] is steam supply temperature)"
    annotation (Placement(transformation(extent={{-92,-70},{-72,-50}})));
  Modelica.Blocks.Math.Gain inv(k=-1) "Invert"
    annotation (Placement(transformation(extent={{20,-40},{0,-20}})));
  SandStorage.Blocks.CarbonEmissions co2e(A=A, filNam=
        "modelica://SandStorage/Resources/Data/CarbonEmissions/5B_Denver_CO.mos")
    "CO2e emissions"
    annotation (Placement(transformation(extent={{150,30},{170,50}})));
  SandStorage.Blocks.SiteEnergy ESit(n=1, A=A) "Site energy"
    annotation (Placement(transformation(extent={{150,-40},{170,-20}})));
  SandStorage.Blocks.SourceEnergy ESou(
    n=1,
    A=A,                                                 conFac=rNat)
    "Source energy"
    annotation (Placement(transformation(extent={{150,-10},{170,10}})));
  Modelica.Blocks.Sources.IntegerConstant eneTyp(k=1) "Energy type"
    annotation (Placement(transformation(extent={{104,8},{116,21}})));
  Modelica.Blocks.Sources.RealExpression PGriPos(y=max(gri.P.real, 0))
    "Positive power from the grid"
    annotation (Placement(transformation(extent={{100,30},{120,50}})));
  Modelica.Blocks.Sources.RealExpression PGri(y=gri.P.real)
    "Power from the grid (negative if exported renewables)"
    annotation (Placement(transformation(extent={{100,-20},{120,0}})));
  Modelica.Blocks.Continuous.Integrator EWin
    annotation (Placement(transformation(extent={{40,16},{60,36}})));
  Modelica.Blocks.Continuous.Integrator EHea
    annotation (Placement(transformation(extent={{140,-80},{160,-60}})));
  Modelica.Blocks.Sources.RealExpression PHea(y=pla.hea.Q_flow)
    "Power of heater"
    annotation (Placement(transformation(extent={{100,-80},{120,-60}})));
equation
  connect(winTur.vWin, weaBus.winSpe) annotation (Line(points={{-20,32},{-20,70}},
        color={0,0,127},
      pattern=LinePattern.Dash),
                          Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(weaDat.weaBus, weaBus) annotation (Line(
      points={{-60,70},{-20,70}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(weaDat.weaBus, pv1.weaBus) annotation (Line(
      points={{-60,70},{-50,70},{-50,2},{-20,2},{-20,-1}},
      color={255,204,51},
      thickness=0.5));
  connect(winTur.P, PRen.u1)
    annotation (Line(points={{-9,26},{2,26},{2,16},{8,16}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(pv1.P, PRen.u2)
    annotation (Line(points={{-9,-3},{2,-3},{2,4},{8,4}},    color={0,0,127},
      pattern=LinePattern.Dash));
  connect(PRen.y, pla.PRen) annotation (Line(points={{31,10},{34,10},{34,-44},{39,
          -44}},color={0,0,127},
      pattern=LinePattern.Dash));
  connect(watIn.ports[1], pla.port_a) annotation (Line(points={{0,-50},{40,-50}},
                            color={238,46,47},
      thickness=0.5));
  connect(pla.port_b, watOut.ports[1]) annotation (Line(points={{59.8,-50},{70,-50},
          {70,-80},{0,-80}}, color={238,46,47},
      thickness=0.5));
  connect(loa.terminal, gri.terminal) annotation (Line(points={{-60,-30},{-70,-30},
          {-70,30}}, color={0,120,120},
      thickness=0.5));
  connect(pv1.terminal, gri.terminal) annotation (Line(points={{-30,-10},{-70,-10},
          {-70,30}}, color={0,120,120},
      thickness=0.5));
  connect(winTur.terminal, gri.terminal)
    annotation (Line(points={{-30,20},{-70,20},{-70,30}}, color={0,120,120},
      thickness=0.5));
  connect(disDat.y[1], watIn.m_flow_in) annotation (Line(points={{-71,-60},{-30,
          -60},{-30,-42},{-22,-42}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(pla.P, inv.u) annotation (Line(points={{62,-44},{70,-44},{70,-30},{22,
          -30}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(inv.y, loa.Pow)
    annotation (Line(points={{-1,-30},{-40,-30}}, color={0,0,127},
      pattern=LinePattern.Dash));
  connect(eneTyp.y, ESou.typSou[1]) annotation (Line(points={{116.6,14.5},{130,
          14.5},{130,6},{148,6}}, color={255,127,0}));
  connect(PGriPos.y, co2e.PEle)
    annotation (Line(points={{121,40},{148,40}}, color={0,0,127}));
  connect(PGri.y, ESou.PSit[1]) annotation (Line(points={{121,-10},{130,-10},{
          130,0},{148,0}}, color={0,0,127}));
  connect(PGri.y, ESit.P[1]) annotation (Line(points={{121,-10},{130,-10},{130,
          -30},{148,-30}}, color={0,0,127}));
  connect(winTur.P, EWin.u) annotation (Line(points={{-9,26},{38,26}},
                   color={0,0,127},
      pattern=LinePattern.Dash));
  connect(PHea.y, EHea.u)
    annotation (Line(points={{121,-70},{138,-70}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-100,-100},{180,100}})),
    experiment(
      StopTime=86400,
      Tolerance=1e-06,
      __Dymola_Algorithm="Dassl"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Plants/Examples/SandStorageElectricHeater.mos"
        "Simulate and plot"),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end SandStorageElectricHeater;
