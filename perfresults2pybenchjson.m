function json = perfresults2pybenchjson(results)
machine_info.node = matlab.unittest.internal.getHostname;

commit_info.id = "unversioned";
commit_info.time = NaT;
commit_info.author_time = NaT;
commit_info.dirty = false;

if ~isempty(matlab.project.currentProject)
    commit_info.project = currentProject;
else
    commit_info.project = "";
end

commit_info.branch = "(unknown)";




benchmarks = arrayfun(@convertBenchMark, results);

s.machine_info = machine_info;
s.commit_info = commit_info;
s.benchmarks = benchmarks;
s.datetime = datetime("now");
s.version = "";

json = jsonencode(s);



function b = convertBenchMark(r)

b.group = missing;

b.name = r.Name;
b.fullname = string(r.TestActivity.TestResult(1).TestElement.BaseFolder) + filesep + r.Name;
b.params = missing;
b.param = missing;
b.extra_info = struct;

opts.disable_gc = false;
opts.timer = "tic";
opts.min_rounds = 4;
opts.max_time = Inf;
opts.min_time = r.CalibrationValue;
opts.warmup = true;
b.options = opts;

mt = r.Samples.MeasuredTime;

stats.min = min(mt);
stats.max = max(mt);
stats.mean = mean(mt);
stats.stddev = std(mt);
stats.rounds = numel(mt);
stats.median = median(mt);
stats.iqr = iqr(mt);
stats.q1 = quantile(mt, .25);
stats.q3 = quantile(mt, .75);
iqr_outliers = nnz(...
            mt > stats.mean(mt) + (stats.iqr(mt)/2) | ...
            mt < stats.mean(mt) - (stats.iqr(mt)/2));
stats.iqr_outliers = iqr_outliers;
stddev_outliers = nnz(...
            mt > mean(mt) + std(mt) | ...
            mt < mean(mt) - std(mt));
stats.stddev_outliers = stddev_outliers;

stats.outliers = iqr_outliers + ";" + stddev_outliers;
stats.ld15iqr = NaN;
stats.hd15iqr = NaN;
totalTime = sum(mt);
stats.ops = stats.rounds/totalTime;
stats.total = totalTime;
stats.iterations = 1;
b.stats = stats;


