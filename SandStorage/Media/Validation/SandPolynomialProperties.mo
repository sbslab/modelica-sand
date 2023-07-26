within SandStorage.Media.Validation;
model SandPolynomialProperties
  "Model that tests the implementation of the silica sand properties (polynomial formulation)"
  extends Modelica.Icons.Example;
  package Medium = SandStorage.Media.SandPolynomial;

  parameter Modelica.Units.SI.Temperature TMin=Medium.TMin
    "Minimum temperature for the simulation";
  parameter Modelica.Units.SI.Temperature TMax=Medium.TMax
    "Maximum temperature for the simulation";
  parameter Modelica.Units.SI.Pressure p=Medium.p_default "Pressure";
  parameter Modelica.Units.SI.MassFraction X[Medium.nX]=Medium.X_default
    "Mass fraction";
  parameter Real errRel=0.1 "Relative error used in the check of the state calculations";
  Modelica.Units.SI.Temperature T "Temperature";
  Modelica.Units.NonSI.Temperature_degC T_degC "Celsius temperature";

  Medium.ThermodynamicState state_pTX "Medium state";

  Modelica.Units.SI.Density d "Density";
  Modelica.Units.SI.DynamicViscosity eta "Dynamic viscosity";
  Modelica.Units.SI.SpecificEnthalpy h "Specific enthalpy";
  Modelica.Units.SI.SpecificInternalEnergy u "Specific internal energy";
  Modelica.Units.SI.SpecificEntropy s "Specific entropy";

  Modelica.Units.SI.IsothermalCompressibility kappa
    "Isothermal compressibility";

  Modelica.Units.SI.SpecificHeatCapacity cp "Specific heat capacity";
  Modelica.Units.SI.SpecificHeatCapacity cv "Specific heat capacity";
  Modelica.Units.SI.ThermalConductivity lambda "Thermal conductivity";

  Modelica.Units.SI.AbsolutePressure pMed "Pressure";
  Modelica.Units.SI.Temperature TMed "Temperature";

  Medium.BaseProperties basPro "Medium base properties";
  Medium.ThermodynamicState state_phX "Medium state";

  Modelica.Media.Interfaces.Types.DerDensityByPressure ddpT
    "Density derivative w.r.t. pressure";
  Modelica.Media.Interfaces.Types.DerDensityByTemperature ddTp
    "Density derivative w.r.t. temperature";
  Modelica.Units.SI.Density[Medium.nX] dddX
    "Density derivative w.r.t. mass fraction";

protected
  constant Real conv(unit="1/s") = 1 "Conversion factor to satisfy unit check";

  function checkState "This function checks the absolute error in the state calculations"
    extends Modelica.Icons.Function;
    input Medium.ThermodynamicState state1 "Medium state";
    input Medium.ThermodynamicState state2 "Medium state";
    input Real errAbs=errAbs "Absolute error threshold";
    input String message "Message for error reporting";

  protected
    Real TErrAbs=abs(Medium.temperature(state1)-Medium.temperature(state2))
      "Absolute error in temperature";
  protected
    Real pErrAbs=abs(Medium.pressure(state1)-Medium.pressure(state2))
      "Absolute error in pressure";
  algorithm
    assert(TErrAbs < errAbs, "Absolute temperature error: " + String(TErrAbs) +
       " K. Error in temperature of " + message);
    assert(pErrAbs < errAbs, "Absolute pressure error: " + String(pErrAbs) +
       " Pa. Error in pressure of " + message);
  end checkState;

equation
    // Check the implementation of the base properties
    basPro.p=p;
    basPro.T=T;
    // Check setting the states
    state_pTX = Medium.setState_pTX(p=p, T=T, X=X);
    state_phX = Medium.setState_phX(p=p, h=h, X=X);
   // checkState(state_pTX, state_phX, errRel, "state_phX");

    // Check the implementation of the functions
    ddpT = Medium.density_derp_T(state_pTX);
    ddTp = Medium.density_derT_p(state_pTX);
    dddX   = Medium.density_derX(state_pTX);

    // Compute temperatures that are used as input to the functions
    T = TMin + conv*time * (TMax-TMin);
    T_degC =Modelica.Units.Conversions.to_degC(T);

    // Check the implementation of the functions
    d = Medium.density(state_pTX);
    eta = Medium.dynamicViscosity(state_pTX);
    h = Medium.specificEnthalpy(state_pTX);

    u = Medium.specificInternalEnergy(state_pTX);
    s = Medium.specificEntropy(state_pTX);
    kappa = Medium.isothermalCompressibility(state_pTX);

    cp = Medium.specificHeatCapacityCp(state_pTX);
    cv = Medium.specificHeatCapacityCv(state_pTX);
    lambda = Medium.thermalConductivity(state_pTX);
    pMed = Medium.pressure(state_pTX);
    assert(abs(p-pMed)/p < errRel, "Error in pressure computation.");
    TMed = Medium.temperature(state_phX);
    assert(abs(T-TMed)/T < errRel, "Error in temperature computation.");

   annotation(experiment(Tolerance=1e-6, StopTime=1.0),
__Dymola_Commands(file="modelica://SandStorage/Resources/Scripts/Dymola/Media/Validation/SandPolynomialProperties.mos"
        "Simulate and plot"),
      Documentation(info="<html>
<p>
This example checks thermophysical properties of the medium.
</p>
</html>",
revisions="<html>
<ul>
<li>
January 5, 2023, by Kathryn Hinkelman:<br/>
First implementation
</li>
</ul>
</html>"));
end SandPolynomialProperties;
