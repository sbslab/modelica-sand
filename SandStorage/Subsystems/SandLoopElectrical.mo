within SandStorage.Subsystems;
model SandLoopElectrical
  "Example model to test the sand loop with controls and electrical components"
  extends Modelica.Icons.Example;
  package MediumSan = SandStorage.Media.SandPolynomial (
    T_default=600+273.15);
  package MediumAir = Modelica.Media.Air.ReferenceAir.Air_pT;
  //Buildings.Media.Air;
  //Modelica.Media.Air.ReferenceAir.Air_pT;
  //Modelica.Media.Air.DryAirNasa;
  parameter Modelica.Units.SI.MassFlowRate mSan_flow_nominal = 19.81;
  parameter Modelica.Units.SI.MassFlowRate mAir_flow_nominal=14.63;
   // mSan_flow_nominal*cpSan_default/cpAir_default;
  parameter Modelica.Units.SI.Temperature TSanOut_nominal = 726.9+273.15;
  parameter Modelica.Units.SI.Temperature TSanIn_nominal = 1200+273.15;
  parameter Modelica.Units.SI.Temperature TAirOut_nominal = 1000+273.15;
  parameter Modelica.Units.SI.Temperature TAirIn_nominal = 238+273.15;
  parameter Modelica.Units.SI.AbsolutePressure pAirOut_nominal = 150000;
  parameter Modelica.Units.SI.SpecificHeatCapacityAtConstantPressure cpAir_default=
    MediumAir.specificHeatCapacityCp(
      MediumAir.setState_pTX(
        T=((TAirOut_nominal-TAirIn_nominal)/2+TAirIn_nominal),
        p=pAirOut_nominal))
        "cp default value for air";
  parameter Modelica.Units.SI.SpecificHeatCapacityAtConstantPressure cpSan_default=
    MediumSan.specificHeatCapacityCp(
      MediumSan.setState_pTX(
        T=((TAirOut_nominal-TAirIn_nominal)/2+TAirIn_nominal),
        p=MediumSan.p_default))
        "cp default value for sand";
  parameter Modelica.Units.SI.HeatFlowRate QAir_flow_nominal=
    mAir_flow_nominal*cpAir_default*(TAirOut_nominal-TAirIn_nominal)
    "Nominal heat flow rate";
  parameter Modelica.Units.SI.HeatFlowRate QSan_flow_nominal=
    mSan_flow_nominal*cpSan_default*(TSanIn_nominal-TSanOut_nominal)
    "Nominal heat flow rate";
  parameter Modelica.Units.SI.Volume VTan=30 "Tank volume";
  parameter Modelica.Units.SI.Length hTan=15
    "Height of tank (without insulation)";
  parameter Modelica.Units.SI.Length dIns=0.25 "Thickness of insulation";
  parameter Modelica.Units.SI.ThermalConductivity kIns=0.04
    "Specific heat conductivity of insulation";
  parameter Modelica.Units.SI.Height hHex_a=tan.hTan-1
    "Height of portHex_a of the heat exchanger, measured from tank bottom";
  parameter Modelica.Units.SI.Height hHex_b=1
    "Height of portHex_b of the heat exchanger, measured from tank bottom";
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
  Buildings.Fluid.Storage.StratifiedEnhancedInternalHex tan(
    redeclare package Medium = MediumSan,
    m_flow_nominal=mSan_flow_nominal,
    show_T=true,
    VTan=VTan,
    hTan=hTan,
    dIns=dIns,
    kIns=kIns,
    redeclare package MediumHex = MediumAir,
    hHex_a=hHex_a,
    hHex_b=hHex_b,
    Q_flow_nominal=QAir_flow_nominal,
    TTan_nominal=TSanIn_nominal,
    THex_nominal=TAirIn_nominal,
    mHex_flow_nominal=mAir_flow_nominal)
    "Particle tank with heat exchanger"
    annotation (Placement(transformation(extent={{42,0},{62,20}})));
  Buildings.Fluid.Sources.MassFlowSource_T airIn(
    redeclare package Medium = MediumAir,
    use_m_flow_in=true,
    T=TAirIn_nominal,
    nPorts=1)
    "Inlet air volume"
    annotation (Placement(transformation(extent={{-50,-60},{-30,-40}})));
  SandStorage.BaseClasses.Boundary_pT_highP airOut(
    redeclare package Medium = MediumAir,
    p=pAirOut_nominal,
    nPorts=1)
    "Outlet air volue"
    annotation (Placement(transformation(extent={{-50,-90},{-30,-70}})));

  Modelica.Blocks.Sources.Ramp ramAir(
    height=mAir_flow_nominal,
    duration(displayUnit="h") = 3600,
    offset=0,
    startTime(displayUnit="h") = 3600)   "Mass flow rate signal"
    annotation (Placement(transformation(extent={{-90,-52},{-70,-32}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTAirIn(redeclare package Medium =
        MediumAir, m_flow_nominal=mAir_flow_nominal)
    annotation (Placement(transformation(extent={{-20,-60},{0,-40}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTAirOut(redeclare package
      Medium = MediumAir, m_flow_nominal=mAir_flow_nominal)
    annotation (Placement(transformation(extent={{20,-90},{0,-70}})));
  SandStorage.Equipment.ParticleConveyor mov(
    redeclare package Medium = MediumSan,
    m_flow_nominal=mSan_flow_nominal,
    h=20) "Mover" annotation (Placement(transformation(
        extent={{-10,-10},{10,10}},
        rotation=90,
        origin={-10,20})));
  Buildings.Fluid.HeatExchangers.HeaterCooler_u hea(
    redeclare package Medium = MediumSan,
    m_flow_nominal=mSan_flow_nominal,
    show_T=true,
    dp_nominal=0,
    Q_flow_nominal=QSan_flow_nominal)
    "Particle heater"
    annotation (Placement(transformation(extent={{0,40},{20,60}})));
  Modelica.Blocks.Logical.Hysteresis staMov(uLow=1e-4, uHigh=1e-2)
    "Mover state"
    annotation (Placement(transformation(extent={{-78,-10},{-58,10}})));
  Buildings.Controls.OBC.CDL.Conversions.BooleanToReal booToRea(realTrue=
        mSan_flow_nominal)
    annotation (Placement(transformation(extent={{-52,-10},{-32,10}})));
  SandStorage.BaseClasses.Boundary_pT_highP pRefSan(redeclare package Medium = MediumSan,
      nPorts=1) "Reference pressure sand"
    annotation (Placement(transformation(extent={{10,-10},{0,0}})));
  SandStorage.Equipment.BaseClasses.ParticleHeaterControl con(
    TMaxSet=1873.15,
    TTan_nominal=1473.15,
    m_flow_nominal=mSan_flow_nominal,
    cp=cpSan_default,
    P_nominal=QSan_flow_nominal) "Particle heater control"
    annotation (Placement(transformation(extent={{-60,46},{-40,66}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTSanOut(redeclare package
      Medium = MediumSan, m_flow_nominal=mSan_flow_nominal)
    "Sand leaving the tank"
    annotation (Placement(transformation(extent={{72,0},{92,20}})));
  Buildings.Fluid.Sensors.TemperatureTwoPort senTSanIn(redeclare package Medium =
        MediumSan, m_flow_nominal=mSan_flow_nominal) "Sand entering the tank"
    annotation (Placement(transformation(extent={{30,40},{50,60}})));
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
    annotation (Placement(transformation(extent={{-150,30},{-130,50}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.WindTurbine winTur(
    V_nominal=V_nominal,
    h=15,
    hRef=10,
    pf=0.94,
    eta_DCAC=0.92,
    nWin=0.4,
    tableOnFile=false,
    scale=PWin) "Wind turbine model"
    annotation (Placement(transformation(extent={{-150,60},{-130,80}})));
  Buildings.BoundaryConditions.WeatherData.ReaderTMY3 weaDat(
      computeWetBulbTemperature=false, filNam=
        Modelica.Utilities.Files.loadResource("modelica://SandStorage/Resources/weatherdata/Denver.mos"))
    "Weather data model"
    annotation (Placement(transformation(extent={{-200,110},{-180,130}})));
  Modelica.Blocks.Math.Add PRen(y(unit="W")) "Renewable power on site"
    annotation (Placement(transformation(extent={{-110,50},{-90,70}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Sources.Grid gri(f=60, V=
        V_nominal)
    "Grid model that provides power to the system"
    annotation (Placement(transformation(extent={{-200,80},{-180,100}})));
  Buildings.Electrical.AC.ThreePhasesBalanced.Loads.Inductive loa(
    mode=Buildings.Electrical.Types.Load.VariableZ_P_input,
    V_nominal=V_nominal,
    linearized=false,
    use_pf_in=false,
    pf=1)
    "Electrical load of the plant"
    annotation (Placement(transformation(extent={{-180,10},{-160,30}})));
  Buildings.BoundaryConditions.WeatherData.Bus weaBus "Weather data bus"
    annotation (Placement(transformation(extent={{-150,110},{-130,130}})));
  Modelica.Blocks.Math.Add PLoa(
    y(unit="W"),
    k1=-1,
    k2=-1) "Renewable power on site"
    annotation (Placement(transformation(extent={{-110,10},{-130,30}})));
equation
  connect(ramAir.y, airIn.m_flow_in)
    annotation (Line(points={{-69,-42},{-52,-42}}, color={0,0,127}));
  connect(airIn.ports[1], senTAirIn.port_a)
    annotation (Line(points={{-30,-50},{-20,-50}}, color={0,127,255}));
  connect(senTAirIn.port_b, tan.portHex_a) annotation (Line(points={{0,-50},{30,
          -50},{30,6.2},{42,6.2}}, color={0,127,255}));
  connect(tan.portHex_b, senTAirOut.port_a) annotation (Line(points={{42,2},{34,
          2},{34,-80},{20,-80}}, color={0,127,255}));
  connect(senTAirOut.port_b, airOut.ports[1])
    annotation (Line(points={{0,-80},{-30,-80}}, color={0,127,255}));
  connect(staMov.y, booToRea.u)
    annotation (Line(points={{-57,0},{-54,0}}, color={255,0,255}));
  connect(booToRea.y, mov.m_flow_in)
    annotation (Line(points={{-30,0},{-5,0},{-5,8}}, color={0,0,127}));
  connect(mov.port_b, hea.port_a)
    annotation (Line(points={{-10,30},{-10,50},{0,50}}, color={0,127,255}));
  connect(pRefSan.ports[1], mov.port_a)
    annotation (Line(points={{0,-5},{-10,-5},{-10,10}}, color={0,127,255}));
  connect(hea.port_b, senTSanIn.port_a)
    annotation (Line(points={{20,50},{30,50}}, color={0,127,255}));
  connect(senTSanIn.port_b, tan.port_a) annotation (Line(points={{50,50},{60,50},
          {60,30},{30,30},{30,10},{42,10}}, color={0,127,255}));
  connect(tan.port_b, senTSanOut.port_a)
    annotation (Line(points={{62,10},{72,10}}, color={0,127,255}));
  connect(senTSanOut.port_b, mov.port_a) annotation (Line(points={{92,10},{96,
          10},{96,-22},{-10,-22},{-10,10}}, color={0,127,255}));
  connect(senTSanIn.T, con.T) annotation (Line(points={{40,61},{40,80},{-70,80},
          {-70,62},{-62,62}}, color={0,0,127}));
  connect(con.y, hea.u)
    annotation (Line(points={{-39,56},{-2,56}}, color={0,0,127}));
  connect(con.y, staMov.u) annotation (Line(points={{-39,56},{-30,56},{-30,30},
          {-88,30},{-88,0},{-80,0}}, color={0,0,127}));
  connect(winTur.vWin,weaBus. winSpe) annotation (Line(points={{-140,82},{-140,120}},
        color={0,0,127}), Text(
      string="%second",
      index=1,
      extent={{-3,6},{-3,6}},
      horizontalAlignment=TextAlignment.Right));
  connect(weaDat.weaBus,weaBus)  annotation (Line(
      points={{-180,120},{-140,120}},
      color={255,204,51},
      thickness=0.5), Text(
      string="%second",
      index=1,
      extent={{6,3},{6,3}},
      horizontalAlignment=TextAlignment.Left));
  connect(weaDat.weaBus,pv1. weaBus) annotation (Line(
      points={{-180,120},{-170,120},{-170,52},{-140,52},{-140,49}},
      color={255,204,51},
      thickness=0.5));
  connect(winTur.P,PRen. u1)
    annotation (Line(points={{-129,76},{-118,76},{-118,66},{-112,66}},
                                                            color={0,0,127}));
  connect(pv1.P,PRen. u2)
    annotation (Line(points={{-129,47},{-118,47},{-118,54},{-112,54}},
                                                             color={0,0,127}));
  connect(loa.terminal,gri. terminal) annotation (Line(points={{-180,20},{-190,20},
          {-190,80}},color={0,120,120}));
  connect(pv1.terminal,gri. terminal) annotation (Line(points={{-150,40},{-190,40},
          {-190,80}},color={0,120,120}));
  connect(winTur.terminal,gri. terminal)
    annotation (Line(points={{-150,70},{-190,70},{-190,80}},
                                                          color={0,120,120}));
  connect(PRen.y, con.PRen) annotation (Line(points={{-89,60},{-74,60},{-74,48},
          {-62,48}}, color={0,0,127}));
  connect(PLoa.y, loa.Pow)
    annotation (Line(points={{-131,20},{-160,20}}, color={0,0,127}));
  connect(hea.Q_flow, PLoa.u1) annotation (Line(points={{21,56},{24,56},{24,34},
          {-26,34},{-26,26},{-108,26}}, color={0,0,127}));
  connect(mov.P, PLoa.u2) annotation (Line(points={{-18,31},{-24,31},{-24,20},{-100,
          20},{-100,14},{-108,14}}, color={0,0,127}));
  annotation (Icon(coordinateSystem(preserveAspectRatio=false)), Diagram(
        coordinateSystem(preserveAspectRatio=false, extent={{-220,-100},{100,140}})),
    experiment(
      StopTime=86400,
      Tolerance=1e-06,
      __Dymola_Algorithm="Radau"),
    __Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Subsystems/SandLoopElectrical.mos"
        "Simulate and plot"),
    Documentation(revisions="<html>
<ul>
<li>
June 9, 2023, by Kathryn Hinkelman:<br/>
First implementation.
</li>
</ul>
</html>"));
end SandLoopElectrical;
