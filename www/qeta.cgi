#!/usr/bin/perl
#
# Perl script to call FriCAS with QEta stuff
#
# Ralf Hemmecke <ralf@hemmecke.org>
#

# Needed to get the parameters to the CGI script.
require RiscCGI;

# Get the cgi-arguments to the script.
%QUERY_ARRAY = RiscCGI::Args();

###################################################################

if (!defined($QUERY_ARRAY{"level"})) {
    $level = "4";
} else {
    $level = $QUERY_ARRAY{"level"};
    delete($QUERY_ARRAY{"level"});
}

if (!defined($QUERY_ARRAY{"rvectors"})) {
    $rvectors = "";
} else {
    $rvectors = $QUERY_ARRAY{"rvectors"};
    delete($QUERY_ARRAY{"rvectors"});
}

if (!defined($QUERY_ARRAY{"gamma"})) {
    $gamma = "";
} else {
    $gamma = $QUERY_ARRAY{"gamma"};
    delete($QUERY_ARRAY{"gamma"});
}

if (!defined($QUERY_ARRAY{"streamcalculate"})) {
    $streamcalculate = "4";
} else {
    $streamcalculate = $QUERY_ARRAY{"streamcalculate"};
    delete($QUERY_ARRAY{"streamcalculate"});
    if($streamcalculate > 50){$streamcalculate="50";}
}


###################################################################

print "Content-type: text/html\n\n";

print <<EOF;
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
  <head>
    <meta charset="utf-8">
    <title>Eta Quotient Expansions</title>
  </head>

  <body>
    <h1>Eta Quotient Expansions</h1>

    <p>
    Here one can compute the expansion of
    g_r(δ(γτ)) = Product_{δ|N} η(δτ)^(r_δ) for given exponent vectors
    r = (r(δ_1), ..., r(δ_n)) where n is the number of positive
    divisors of N.
    </p>
    <p>
    <form action="/people/hemmecke/qeta/qeta.cgi" method="get">
    <input type="submit" value="Compute" />
    <dl>
    <dt><strong>Level:</strong></dt>
    <dd><input name="level" value="$level" size=3 /></dd>

    <dt><strong>List of m exponent vectors</strong> in the form
    [[r11,r12,...,r1n],...,[rm1,...,rmn]] with n being the number of
    divisors of level
    (leave empty to get a monoid basis corresponding to all
    eta-quotients that are modular functions).
    <br />
    <dd><input name="rvectors" value="$rvectors" size=40 /></dd>

    <dt><strong>Transformation matrix γ</strong> from SL_2(Z) in the form
    [[a, b], [c,d]] (leave empty to expand at every cusp of
    Gamma_0(level)).
    <dd><input name="gamma" value="$gamma" size=40 /></dd>

    <dt><strong>Show k coefficients</strong> (default k=4):</dt>
    <dd><input name="streamcalculate" value="$streamcalculate" size=3 /></dd>
    </dl>
    </form>
    </p>
    <pre>
EOF

###################################################################

if ($rvectors eq '') {$rvectors = "eqmevx(m)";}
$rvectors =~ s/ *//g; # remove spaces from rvectors
$cmd="/bin/bash /home/www/people/hemmecke/qeta/qeta/qeta.sh";
$args="--level='\"$level\"' --calc='\"$streamcalculate\"' --rvectors='\"$rvectors\"' --gamma='\"$gamma\"'";

#print "CMD=[$cmd]\n";
#print "ARGS={$args}\n";

$out=`ssh -oStrictHostKeyChecking=no compute.risc.jku.at $cmd $args`;
print "$out";

###################################################################

print <<'EOF';
    </pre>
    <hr>
    <address>
      <a href="mailto:hemmecke@risc.jku.at">Ralf Hemmecke</a>
    </address>
  </body>
</html>
EOF
