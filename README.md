# mi-DS
Multiple Instance Data Squeezer
Implementation of mi-DS, a rule based Algorithm. Used for Data Mining and creating Machine Learning model to classify the future instances of data.

Implemented in MATLAB and tested on a toy dataset as well as Musk data from UC Irvine Repositories.

Paper - 
Nguyen, D.T.; Nguyen, C.D.; Hargraves, R.; Kurgan, L.A.; Cios, K.J., "mi-DS: Multiple-Instance Learning Algorithm," in Cybernetics, IEEE Transactions on , vol.43, no.1, pp.143-154, Feb. 2013
doi: 10.1109/TSMCB.2012.2201468
Abstract: Multiple-instance learning (MIL) is a supervised learning technique that addresses the problem of classifying bags of instances instead of single instances. In this paper, we introduce a rule-based MIL algorithm, called mi-DS, and compare it with 21 existing MIL algorithms on 26 commonly used data sets. The results show that mi-DS performs on par with or better than several well-known algorithms and generates models characterized by balanced values of precision and recall. Importantly, the introduced method provides a framework that can be used for converting other rule-based algorithms into MIL algorithms.

URL: http://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=6220277&isnumber=6340245
URL: https://www.researchgate.net/publication/260586908_mi-DS_Multiple-Instance_Learning_Algorithm

keywords: {knowledge based systems;learning (artificial intelligence);pattern classification;bags of instances classification;mi-DS;multiple-instance learning algorithm;precision and recall;rule-based MIL algorithm;supervised learning;Classification algorithms;Educational institutions;Prediction algorithms;Proteins;Standards;Support vector machines;Training data;Multiple-instance learning (MIL);rule-based algorithms;supervised learning},

Repository - 
http://archive.ics.uci.edu/ml/datasets/Musk+%28Version+1%29

I used MATLAB R2015a (8.5.0.197613) Pro for this project.

Step-by-step guide to run the code: -

1.	Run the ‘arff_to_xsls.m’ to convert the *arff file to an *xlsx format.
2.	Convert both the training and the test data to *xlsx format.
3.	Run ‘mi-DS.m’
4.	Select the training file we converted to excel.
5.	Next select the test data to check the result, And compare the test bag with the similarity matrix from the training bags
