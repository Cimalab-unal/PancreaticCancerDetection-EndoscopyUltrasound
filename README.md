## Under revision

# A robust descriptor of the pancreas tissue for automatic detection of pancreatic cancer in endoscopic ultrasonography 

**Authors**: 
Josué Ruano(a), María Jaramillo(a), Martín Gómez(b), and Eduardo Romero(a) 

**Affiliations:**
(a) CIM@LAB, Universidad Nacional de Colombia, (b) Medicina Interna, Universidad Nacional de Colombia 

## Abstract 

Pancreatic Cancer (PC) has reported mortality of 98% and a 5-year survival rate of 6.7%. Experienced gastroenterologists find out 80% of the early stages with
endoscopic ultrasonography (EUS). This paper proposes an automatic second reader
strategy to detect PC in an entire EUS procedure, rather than focusing on pre-selected frames, as the state-of-the-art methods do. The method unmasks echo tumoral patterns in frames with high probability of tumor. First, Speeded-Up Robust Features define a set of interest points with correlated heterogeneities among different filtering scales. Afterward, intensity gradients of each interest point are summarized by 64 features at certain locations and scales. A frame feature vector is built by concatenating statistics of each feature of the 15 groups of scales. Then, binary classification is performed by Support Vector Machine and Adaboost models. Evaluation was performed using a data set with 55 subjects, 18 of PC class (16,585 frames), and 37 subjects of non-PC class (49,664 frames), randomly splitting ten times. The proposed method reached an accuracy of 92.1%, sensitivity of 96.3%, and specificity of 87.8.3%. The observed results are also stable in noisy experiments while deep learning approaches fail to maintain similar performance.