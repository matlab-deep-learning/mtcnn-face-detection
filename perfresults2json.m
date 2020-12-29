function json = perfresults2json(results)

c.date = datetime('now');
c.host_name = results(1).Samples.Host(1);
%c.executable = 'MATLAB';
%c.num_cpus = NaN;
%c.mhz_per_cpu = NaN;
%c.cpu_scaling_enabled = false;
%c.caches = NaN;

samples = vertcat(results.Samples);

for thisSampleIdx = height(samples):-1:1
    thisSample = samples(thisSampleIdx,:);
    b = struct;
    b.name = thisSample.Name;
    b.iterations = 1;
    b.real_time = round(thisSample.MeasuredTime*1e9);
    b.cpu_time = b.real_time;
    b.time_unit = "ns";
    b.threads = 1;
    
    benchmarks(thisSampleIdx) = b;
end

s.context = c;
s.benchmarks = benchmarks;
json = jsonencode(s);
