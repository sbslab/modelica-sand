within SandStorage.Media;
package SandPolynomial
  "Package with model for silica sand with polynomial property functions"
  extends Modelica.Media.Interfaces.PartialMedium(
    mediumName="sand",
    final substanceNames={"silicaSand"},
    singleState=true,
    reducedX=true,
    fixedX=true,
    FluidConstants={Modelica.Media.IdealGases.Common.FluidData.SiO2},
    reference_T=298.15,
    reference_p=101325,
    reference_X={1},
    AbsolutePressure(start=p_default),
    Temperature(start=T_default),
    SpecificEnthalpy(start=h_default, nominal=h_default),
    SpecificEntropy(start=689.7, nominal=689.7),
    Density(start=2650.0, nominal=2650.0),
    T_default=Modelica.Units.Conversions.from_degC(100),
    p_default=101325,
    h_default=15160732.4);
  extends Modelica.Icons.Package;

  constant SpecificEnthalpy reference_h=15160732.4
    "Reference h of Medium";
  constant SpecificEntropy reference_s=689.7
    "Reference s of Medium";
/*  constant SpecificHeatCapacity cp_const
    "Constant specific heat capacity at constant pressure";
  constant SpecificHeatCapacity cv_const
  "Constant specific heat capacity at constant volume";
*/
  constant Density d_const=2650 "Constant density";
  constant AbsolutePressure p_const=101325 "Constant pressure";
  constant ThermalConductivity lambda_const=0.7 "Constant conductivity";
  constant Real sphericity = 0.7 "Sphericity of particles (range: 0.6-0.7) [unitless]";
  constant Modelica.Units.SI.Length d_particles = 556e-6 "Sauter mean diameter of particles [m]";
  constant Modelica.Units.SI.Density dddvoid = -2767.5 "Derivative of particle density w.r.t. void fraction";
  constant Temperature TMax = 2000 "Maximum temperature";
  constant Temperature TMin = 298 "Minimum temperature";
  constant SpecificEnthalpy hMin = 0 "Minimum enthalpy";
  constant SpecificEnthalpy hMax = 200.0e3 "Maximum enthalpy";
  constant SpecificEntropy sMin = 0 "Minimum entropy";
  constant SpecificEntropy sMax = 1.0e3 "Maximum entropy";

  redeclare record ThermodynamicState
    "Thermodynamic state variables"
    Temperature T "Temperature of medium";
   // Modelica.Units.SI.AbsolutePressure p "Density of medium";
  end ThermodynamicState;

redeclare replaceable model extends BaseProperties(
    preferredMediumStates=true,
    standardOrderComponents=true)
    "Base properties (p, d, T, h, u, R, MM)"
equation
    d = d_const;
 //   p = p_const;
    MM = sand.MM;
    R_s = sand.R;
    u = h - p_const/d_const;
    h = specificEnthalpy(state);
    state.T = T;
end BaseProperties;

redeclare replaceable function extends density
  "Returns density"
algorithm
  d := d_const;
  annotation (Inline=true, Documentation(info="<html>
<p>
Constant density.
</p>
</html>"));
end density;

redeclare replaceable function extends dynamicViscosity
    "Return dynamic viscosity"
  //constant Real a[3] = {0.0373,-60.684,25825} "Regression coefficients";
  protected
  constant Real k = 2.074353e5 "Scaling constant";
  constant Real p = -2.837789 "Power exponent";
    // {0.0373,-60.684,25825} quadratic fit
    // {-0.0001,0.3343,-266.89,72936} cubic fit
algorithm
  //    eta := (a[1]*state.T^2 + a[2]*state.T + a[3])/1e6;
  eta := k*state.T^p;
    annotation (Inline=true,smoothOrder=3,Documentation(info="<html>
<p>
Dynamic viscosity is computed from temperature using a 3rd order polynomial.
</p>
</html>"));
end dynamicViscosity;

redeclare replaceable function extends molarMass
  "Return the molar mass of the medium"
algorithm
  MM := sand.MM;
    annotation (Documentation(info="<html>
<p>
Returns the molar mass.
</p>
</html>"));
end molarMass;

redeclare function extends pressure
  "Return pressure"
algorithm
  p := p_const;
    annotation (Documentation(info="<html>
<p>
Constant pressure.
</p>
</html>"));
end pressure;

redeclare replaceable function extends specificEnthalpy
  "Returns specific enthalpy"
algorithm
  h := h_T(state.T);
annotation (Inline=true,smoothOrder=2,
    Documentation(info="<html>
<p>
Returns the specific enthalpy.
</p>
</html>"));
end specificEnthalpy;

redeclare replaceable function extends specificEntropy
  "Return specific entropy"
algorithm
  s := s_T(state.T);
annotation (Inline=true,smoothOrder=1,
    Documentation(info="<html>
<p>
Returns the specific entropy.
</p>
</html>"));
end specificEntropy;

redeclare replaceable function extends specificInternalEnergy
  "Return specific internal energy"
algorithm
  u := specificEnthalpy(state) - p_const/d_const;
  annotation (Inline=true, Documentation(info="<html>
<p>
Returns the specific internal energy for a given state.
</p>
</html>"));
end specificInternalEnergy;

redeclare replaceable function extends specificHeatCapacityCp
  "Specific heat capacity at constant pressure"
algorithm
  cp := cp_T(state.T);
  annotation (
    smoothOrder=1,
    Inline=true,
      Documentation(info="<html>
<p>
Specific heat at constant pressure is computed from temperature and
pressure using the IAPWS-IF97 relationship via the Gibbs
free energy for region 2.
</p>
</html>"));
end specificHeatCapacityCp;

redeclare replaceable function extends specificHeatCapacityCv
  "Specific heat capacity at constant volume"
algorithm
  cv := specificHeatCapacityCp(state);
  annotation (
    smoothOrder=2,
    Inline=true,
    LateInline = true,
      Documentation(info="<html>
<p>
Specific heat at constant volume is computed from temperature and
pressure using the IAPWS-IF97 relationship via the Gibbs
free energy for region 2.
</p>
</html>",
revisions="<html>
<ul>
<li>
December 6, 2020, by Michael Wetter:<br/>
Added <code>LateInline=true</code>.
This is required for OCT-r17595_JM-r14295, otherwise
<a href=\"modelica://Buildings.Media.Examples.SteamDerivativeCheck\">
Buildings.Media.Examples.SteamDerivativeCheck</a>
does not translate.
</li>
</ul>
</html>"));
end specificHeatCapacityCv;

redeclare replaceable function extends specificGibbsEnergy
   "Specific Gibbs energy"
algorithm
  g := specificEnthalpy(state) - state.T*specificEntropy(state);
  annotation (Inline=true);
end specificGibbsEnergy;

redeclare replaceable function extends specificHelmholtzEnergy
   "Specific Helmholtz energy"
algorithm
  f := specificEnthalpy(state) - sand.R*state.T - state.T*specificEntropy(state);
  annotation (Inline=true, Documentation(info="<html>
<p>
Returns the specific Helmholtz energy for a given state.
</p>
</html>"));
end specificHelmholtzEnergy;

redeclare replaceable function extends setState_dTX
    "Return the thermodynamic state as function of d and T"
algorithm
  state := ThermodynamicState(T=T);
annotation (Inline=true,
      Documentation(info="<html>
<p>
The <a href=\"modelica://Modelica.Media.Interfaces.PartialMixtureMedium.ThermodynamicState\">thermodynamic state record</a>
is computed from density <code>d</code> and temperature <code>T</code>.
</p>
</html>"));
end setState_dTX;

redeclare replaceable function extends setState_pTX
    "Return the thermodynamic state as function of p and T"
algorithm
  state := ThermodynamicState(T=T);
annotation (Inline=true,smoothOrder=2,
    Documentation(info="<html>
<p>
The <a href=\"modelica://Modelica.Media.Interfaces.PartialMixtureMedium.ThermodynamicState\">thermodynamic state record</a>
is computed from pressure <code>p</code> and temperature <code>T</code>.
</p>
</html>"));
end setState_pTX;

redeclare replaceable function extends setState_phX
    "Return the thermodynamic state as function of p and h"
algorithm
  state := ThermodynamicState(T=T_h(h));
annotation (Inline=true,
      Documentation(info="<html>
<p>
The <a href=\"modelica://Modelica.Media.Interfaces.PartialMixtureMedium.ThermodynamicState\">thermodynamic state record</a>
is computed from pressure <code>p</code> and specific enthalpy <code>h</code>.
</p>
</html>"));
end setState_phX;

redeclare replaceable function extends setState_psX
    "Return the thermodynamic state as function of p and s"
algorithm
  state := ThermodynamicState(T=T_s(s));
annotation (Inline=true,
    Documentation(info="<html>
<p>
The <a href=\"modelica://Modelica.Media.Interfaces.PartialMixtureMedium.ThermodynamicState\">thermodynamic state record</a>
is computed from pressure <code>p</code> and specific entropy <code>s</code>.
</p>
</html>"));
end setState_psX;

redeclare function extends temperature
    "Return temperature"
algorithm
  T := state.T;
    annotation (Documentation(info="<html>
<p>
Temperature is returned from the thermodynamic state record input as a simple assignment.
</p>
</html>"));
end temperature;

redeclare replaceable function extends thermalConductivity
  "Return thermal conductivity"
algorithm
  lambda := lambda_const;
  annotation (Inline=true, Documentation(info="<html>
<p>
Constant thermal conductivity.
</p>
</html>"));
end thermalConductivity;

redeclare replaceable function extends isothermalCompressibility
  "Isothermal compressibility"
algorithm
  kappa := 0;
  annotation (Inline=true, Documentation(info="<html>
<p>
Simple assignment.
</p>
</html>"));
end isothermalCompressibility;

redeclare replaceable function extends isobaricExpansionCoefficient
  "Isobaric expansion coefficient"
algorithm
  beta := 0;
    annotation (Documentation(info="<html>
<p>
Simple assignment.
</p>
</html>"));
end isobaricExpansionCoefficient;
// Derivative functions
redeclare function extends density_derp_h
  "Return density derivative w.r.t. pressure at const specific enthalpy"
algorithm
  ddph := 0;
end density_derp_h;

redeclare function extends density_derh_p
  "Return density derivative w.r.t. specific enthalpy at constant pressure"
algorithm
  ddhp := 0;
end density_derh_p;

redeclare function extends density_derp_T
  "Return density derivative w.r.t. pressure at const temperature"
algorithm
  ddpT := 0;
end density_derp_T;

redeclare function extends density_derT_p
  "Return density derivative w.r.t. temperature at constant pressure"
algorithm
  ddTp := 0;
end density_derT_p;

redeclare function extends density_derX
  "Return density derivative w.r.t. mass fraction"
algorithm
  dddX[nX] := 0;
end density_derX;
//////////////////////////////////////////////////////////////////////
// Protected classes
protected
record GasProperties
  "Coefficient data record for properties of perfect gases"
  extends Modelica.Icons.Record;
    Modelica.Units.SI.MolarMass MM "Molar mass";
    Modelica.Units.SI.SpecificHeatCapacity R "Gas constant";
end GasProperties;
  constant GasProperties sand(R=Modelica.Media.IdealGases.Common.SingleGasesData.SiO2.R_s,
      MM=Modelica.Media.IdealGases.Common.SingleGasesData.SiO2.MM)
    "Sand (SiO2) properties";

function cp_T
  "Return cp from T, with input u=T and output y=cp"
  extends Modelica.Math.Nonlinear.Interfaces.partialScalarFunction;
  protected
  constant Real a[4] = {2.799140e-6,-5.394235e-3,4.181354,-9.929403e1}
      "Regression coefficients, first half";
  constant Real b[2] = {1.671556e-1,9.804303e+2}
      "Regression coefficients, second half";
  constant Temperature T_inflection = 800
    "Inflection point where the two polynomial curves meet [K]";
  constant Temperature T1=T_inflection-dT
    "Lower abscissa value for the temperature spline";
  constant Temperature T2=T_inflection+dT
    "Upper abscissa value for the temperature spline";
  constant Modelica.Units.SI.TemperatureDifference dT = 1e-6
    "Small delta T over which smoothing occurs";
algorithm
  if u < T1 then
    y := a[1]*u^3+a[2]*u^2+a[3]*u+a[4];
  elseif u > T2 then
    y := b[1]*u+b[2];
  else
    y := Modelica.Fluid.Utilities.cubicHermite(
      x=u,
      x1=T1,
      x2=T2,
      y1=a[1]*T1^3+a[2]*T1^2+a[3]*T1+a[4],
      y2=b[1]*T2+b[2],
      y1d=3*a[1]*T1^2+2*a[2]*T1+a[3],
      y2d=T2+b[1]);
  end if;
annotation (Inline=true,smoothOrder=2);
end cp_T;

function T_h
  "Return temperature from h, backward function of h(T) [not an analytic inverse]"
  extends Modelica.Math.Nonlinear.Interfaces.partialScalarFunction;
  protected
  constant Real a[3] = {-5.724281e-5,2.698088,-2.742347e4}
    "Regression coefficients";
algorithm
    y := a[1]*(u/1000)^2 + a[2]*(u/1000) + a[3];
annotation (Inline=true,smoothOrder=2);
end T_h;

function T_s
  "Return temperature from s, backward function of s(T) [not an analytic inverse]"
  extends Modelica.Math.Nonlinear.Interfaces.partialScalarFunction;
  protected
  constant Real a[3] = {3.931772e-5,3.166628e-1,6.269179e1}
    "Regression coefficients, first equation";
  constant Real b[7] = {-1.045081e-15,1.606278e-11,-1.021672e-7,3.441257e-4,
    -6.470833e-1,6.444873e2,-2.651469e5}
    "Regression coefficients, second equation";
  constant SpecificEntropy s_inflection = 1767.2361
    "Inflection point where the two polynomial curves meet [J/kg-K]";
  constant SpecificEntropy s1=s_inflection-ds
    "Lower abscissa value for the s spline";
  constant SpecificEntropy s2=s_inflection+ds
    "Upper abscissa value for the s spline";
  constant SpecificEntropy ds = 1e-6
    "Small delta s over which smoothing occurs";
algorithm
  if u < s1 then
    y := a[1]*u^2+a[2]*u+a[3];
  elseif u > s2 then
    y := b[1]*u^6+b[2]*u^5+b[3]*u^4+b[4]*u^3+b[5]*u^2+b[6]*u+b[7];
  else
    y := Modelica.Fluid.Utilities.cubicHermite(
      x=u,
      x1=s1,
      x2=s2,
      y1=a[1]*s1^2+a[2]*s1+a[3],
      y2=b[1]*s2^6+b[2]*s2^5+b[3]*s2^4+b[4]*s2^3+b[5]*s2^2+b[6]*s2+b[7],
      y1d=3*a[1]*s1+2*a[2],
      y2d=6*b[1]*s2^5+5*b[2]*s2^4+4*b[3]*s2^3+3*b[4]*s2^2+2*b[5]*s2+b[6]);
  end if;
annotation (Inline=true,smoothOrder=2,
    Documentation(info="<html>
<p>
Returns temperature from specific entropy.
</p>
</html>"));
end T_s;

function h_T
  "Return h from T"
  extends Modelica.Math.Nonlinear.Interfaces.partialScalarFunction;
  protected
  constant Real a[4] = {-0.00003136258,0.2012222,846.2066,14875620}
    "Regression coefficients";
algorithm
    y := a[1]*u^3 + a[2]*u^2 + a[3]*u + a[4];
annotation (Inline=true,smoothOrder=3,
    Documentation(info="<html>
<p>
Returns specific enthalpy from temperature.
</p>
</html>"));
end h_T;

function s_T
  "Return s from T"
  extends Modelica.Math.Nonlinear.Interfaces.partialScalarFunction;
algorithm
  y := reference_s + cp_T(u)*log(u/reference_T);
annotation (Inline=true,smoothOrder=2,
    Documentation(info="<html>
<p>
Returns specific entropy from temperature.
</p>
</html>"));
end s_T;
  annotation (
  Documentation(info="<html>
<p>
This medium package models silica sand with polynomial functions.
</p>
<h4>Applications </h4>
<p>
This model is intended for fluidized sand heating applications. 
</p>
<h4>References </h4>
<p>[tbd]
</p>
</html>", revisions="<html>
<ul>
<li>
January 5, 2023, by Kathryn Hinkelman:<br/>
First implementation
</li>
</ul>
</html>"), Icon(graphics={
        Ellipse(
          extent={{-72,36},{-32,10}},
          lineColor={127,127,0},
          fillColor={185,173,35},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{0,0},{30,-48}},
          lineColor={127,127,0},
          fillColor={185,173,35},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-76,-22},{-18,-72}},
          lineColor={127,127,0},
          fillColor={185,173,35},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{36,56},{74,24}},
          lineColor={127,127,0},
          fillColor={185,173,35},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{-14,62},{10,24}},
          lineColor={127,127,0},
          fillColor={185,173,35},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{50,-50},{84,-80}},
          lineColor={127,127,0},
          fillColor={185,173,35},
          fillPattern=FillPattern.Solid),
        Ellipse(
          extent={{46,-8},{86,-34}},
          lineColor={127,127,0},
          fillColor={185,173,35},
          fillPattern=FillPattern.Solid)}));
end SandPolynomial;
