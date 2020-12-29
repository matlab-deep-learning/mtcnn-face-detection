function runPerfTests

results = runperf("Superclass", "matlab.perftest.TestCase");

json = perfresults2json(results);
[~,~] = mkdir('mtcnn-face-detection');

fid = fopen("mtcnn-face-detection/benchmark-data.json","w","n","UTF-8");
cl = onCleanup(@() fclose(fid));
fprintf(fid,"%s",json);
