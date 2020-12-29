function runPerfTests

results = runperf("Superclass", "matlab.perftest.TestCase");

json = perfresults2json(results);
[~,~] = mkdir('output');

fid = fopen("output/benchmark-result.json","w","n","UTF-8");
cl = onCleanup(@() fclose(fid));
fprintf(fid,"%s",json);
