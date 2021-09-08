# Automatic detection of pancreatic malignant lesions in echoendoscopy 

**Authors**: 
Josué Ruano(a), María Jaramillo(a), Martín Gómez(b), and Eduardo Romero(a) 

**Affiliations:**
(a) CIM@LAB, Universidad Nacional de Colombia, (b) Medicina Interna, Universidad Nacional de Colombia 

## Abstract 

**Background and Aims:** Pancreatic Cancer (PC), one of the most aggressive tumors, has reported mortality of 98% and a 5-year survival rate of 6.7%. Experienced gastroenterologists detect 80% of early stages with endoscopic ultrasonography (EUS). This paper proposes a second reader strategy to detect PC from an entire EUS procedure, rather than focusing on pre-selected frames as the state of the art methods do. 

**Methods:** The method detects echo tumoral patterns in frames with a higher probability of tumor. First, Speeded-Up Robust Features define a set of interest points with correlated heterogeneities among different resolutions. Afterward, intensity gradients of each interest point are summarized by 64 features at certain locations and scales. A per-frame feature vector is built by separately concatenating statistics of each feature among 15 scales. Then, binary classification is performed by Support Vector Machine and Adaboost models. 

**Results:** Evaluation was performed using a data set with 66.249 frames, 16.585 of PC class, and 49,664 of non-PC class, randomly splitting ten times the data set in 70% for training and 30% for testing. The proposed method reached an accuracy of 92.1%, sensitivity of 96.3%, and specificity of 87.8.3%, outperforming results obtained by typical convolutional neural networks. The observed results are stable in noisy experiments while several deep learning approaches fail to maintain similar performance.

**Conclusions:** Results suggest this strategy is suitable for a clinical scenario to support PC diagnosis.