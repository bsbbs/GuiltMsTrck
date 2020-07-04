data {
int<lower=1> maxNtrial;
int<lower=1> Nsubj; // number of subjects
int<lower=1> NTrial[Nsubj]; // number of trials per subject
matrix[Nsubj,maxNtrial] deltatrnsp;
matrix[Nsubj,maxNtrial] deltacomp;
matrix[Nsubj,maxNtrial] angle;// trajectory angle
}
parameters {
// hyper level mean, intermedium variable 
//real mu_beta_pr;
real mu_b1_pr;
real mu_b2_pr;
// real mu_intercept_pr;
// hyper level sd, intermedium variable 
//real<lower=0> sd_beta;
real<lower=0> sd_b1;
real<lower=0> sd_b2;
// real<lower=0> sd_intercept;

// subjective-level raw parameters, declare as vectors for vectorizing
//vector[Nsubj] beta_pr;
vector[Nsubj] b1_pr; 
vector[Nsubj] b2_pr; 
// vector[Nsubj] intercept_pr;

vector<lower=0>[Nsubj] sigmasubj;
}
transformed parameters {
//vector<lower=0,upper=5>[Nsubj] beta;
vector<lower=-50,upper=50>[Nsubj] b1;
vector<lower=-50,upper=50>[Nsubj] b2;
vector[Nsubj] beta;
vector[Nsubj] w1;
vector[Nsubj] w2;
// vector<lower=-10,upper=10>[Nsubj] intercept;

for (subj in 1:Nsubj) {
//beta[subj]    = Phi_approx( mu_beta_pr + sd_beta * beta_pr[subj])*5;
b1[subj] = (Phi_approx( mu_b1_pr + sd_b1 * b1_pr[subj]) - .5) * 100;
b2[subj] = (Phi_approx( mu_b2_pr + sd_b2 * b2_pr[subj]) - .5) * 100;
beta[subj] = fabs(b1[subj]) + fabs(b2[subj]);
w1[subj] = b1[subj]/(fabs(b1[subj]) + fabs(b2[subj]));
w2[subj] = b2[subj]/(fabs(b1[subj]) + fabs(b2[subj]));
// intercept[subj] = (Phi_approx( mu_intercept_pr + sd_intercept * intercept_pr[subj]) - 0.5) * 20;
}
}
model {
// hyperparameters
//mu_beta_pr ~ normal(0, 1);
mu_b1_pr ~ normal(0, 1);
mu_b2_pr ~ normal(0, 1);
// mu_intercept_pr ~ normal(0,1);
//sd_beta  ~ cauchy(0, 5);
sd_b1  ~ cauchy(0, 5);
sd_b2  ~ cauchy(0, 5);
// sd_intercept ~ cauchy(0,5);

// individual parameters
//beta_pr ~ normal(0, 1);
b1_pr ~ normal(0, 1);
b2_pr ~ normal(0, 1);
// intercept_pr ~ normal(0,1);
sigmasubj ~ cauchy(0, 5);
  for (subj in 1:Nsubj) {
      angle[subj,1:NTrial[subj]] ~ normal(b1[subj]*deltacomp[subj,1:NTrial[subj]] + b2[subj]*deltatrnsp[subj,1:NTrial[subj]], sigmasubj[subj]);
      //target += beta[subj];
  }
}

generated quantities {
vector[Nsubj] log_lik;
real      LL_all;
real mu_beta;
real mu_b1;
real mu_b2;
real mu_w1;
real mu_w2;
// real mu_intercept;

mu_b1 = (Phi_approx(mu_b1_pr) - .5)*100;
mu_b2 = (Phi_approx(mu_b2_pr) - .5)*100;
mu_beta    = fabs(mu_b1) + fabs(mu_b2);
mu_w1 = mu_b1/(fabs(mu_b1) + fabs(mu_b2));
mu_w2 = mu_b2/(fabs(mu_b1) + fabs(mu_b2));
// mu_intercept = (Phi_approx(mu_intercept_pr) - 0.5)*20;
for (subj in 1:Nsubj){
  log_lik[subj] = normal_lpdf(angle[subj,1:NTrial[subj]] | b1[subj]*deltacomp[subj,1:NTrial[subj]] + b2[subj]*deltatrnsp[subj,1:NTrial[subj]], sigmasubj[subj]);
}
LL_all=sum(log_lik);
}

