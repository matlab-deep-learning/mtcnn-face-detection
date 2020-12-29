function json = perfresults2json(results)

context.date = datetime('now');
context.host_name = results(1).Samples.Host(1);
%c.executable = 'MATLAB';
%c.num_cpus = NaN;
%c.mhz_per_cpu = NaN;
%c.cpu_scaling_enabled = false;
%c.caches = NaN;

for thisResultIdx = numel(results):-1:1
    thisResult = results(thisResultIdx);
    b = struct;
    b.name = thisResult.Name;
    samples =  height(thisResult.Samples);
    b.iterations = samples;
    b.real_time = round(median(thisResult.Samples.MeasuredTime)*1e3);
    b.cpu_time = b.real_time;
    b.time_unit = "s";
    b.threads = 1;
    
    benchmarks(thisResultIdx) = b;
end

s.context = context;
s.benchmarks = benchmarks;
json = jsonencode(s);
