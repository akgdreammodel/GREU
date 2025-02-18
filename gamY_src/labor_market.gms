# ------------------------------------------------------------------------------
# Variable definitions
# ------------------------------------------------------------------------------
$GROUP+ price_variables
  pL[t] "Usercost of labor."
  pW[t] "Wage pr. efficiency unit of labor."
  pLfrictions[t] "Effect of real and nominal frictions on usercost of labor."
;
$GROUP+ quantity_variables
  qProductivity[t] "Labor augmenting productivity."
  qL[t] "Labor in efficiency units."
  qL_i[i,t] "Labor in efficiency units by industry."
  qLfrictions[t] "Effect of real frictions on efficiency units of labor"
;
$GROUP+ value_variables
  vW[t] "Wage level."
;
$GROUP+ other_variables
  nL[t] "Total employment."
  nL_i[i,t] "Employment by industry."
;

# ------------------------------------------------------------------------------
# Equations
# ------------------------------------------------------------------------------
$BLOCK labor_market $(t1.val <= t.val and t.val <= tEnd.val)
  # Aggregating labor demand from industries
  qL[t].. qL[t] =E= sum(i, qL_i[i,t]);

  # Equilibrium condition: labor demand = labor supply
  pW[t].. qL[t] =E= qProductivity[t] * nL[t] - qLfrictions[t];

  # Usercost of labor is wage + any frictions
  pL[t].. pL[t] =E= pW[t] + pLfrictions[t];

  # Mapping between efficiency units and actual employees and wages
  vW[t].. vW[t] =E= pW[t] * qProductivity[t];
  nL_i[i,t].. nL_i[i,t] / nL[t] =E= qL_i[i,t] / qL[t];
$ENDBLOCK

# Add equation and endogenous variables to main model
model main / labor_market_equations /;
$GROUP+ main_endogenous labor_market_endogenous;

# ------------------------------------------------------------------------------
# Data and exogenous parameters
# ------------------------------------------------------------------------------
$GROUP labor_market_data_variables
  vW[t]
  nL[t]
;
@load(labor_market_data_variables, "../data/data.gdx")
$GROUP+ data_covered_variables labor_market_data_variables;

# ------------------------------------------------------------------------------
# Calibration
# ------------------------------------------------------------------------------
$BLOCK labor_market_calibration $(t1.val <= t.val and t.val <= tEnd.val)
  qProductivity[t]$(t.val > t1.val).. qProductivity[t] =E= qProductivity[t1];
$ENDBLOCK

# Add equations and calibration equations to calibration model
model calibration /
  labor_market_equations
  labor_market_calibration_equations
/;
# Add endogenous variables to calibration model
$GROUP calibration_endogenous
  labor_market_calibration_endogenous
  labor_market_endogenous
  -vW[t1], qProductivity[t1]

  calibration_endogenous
;