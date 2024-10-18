# Robust Descriptor of Pancreatic Tissue for Automatic Detection of Pancreatic Cancer in Endoscopic Ultrasonography

**Authors**: 
Josué Ruano(a), María Jaramillo(a), Martín Gómez(b), and Eduardo Romero(a) 

**Affiliations:**
(a) CIM@LAB, Universidad Nacional de Colombia, (b) Medicina Interna, Universidad Nacional de Colombia 

<img src="pipeline.png?raw=True" width="800px" style="margin:0px 0px"/>

## Abstract 

Pancreatic Cancer (PC) has reported mortality of 98% and a 5-year survival rate of 6.7%. Experienced gastroenterologists find out 80% of the early stages with endoscopic ultrasonography (EUS). This paper proposes an automatic second reader strategy to detect PC in an entire EUS procedure, rather than focusing on pre-selected frames, as the state-of-the-art methods do. The method unmasks echo tumoral patterns in frames with high probability of tumor. First, Speeded-Up Robust Features define a set of interest points with correlated heterogeneities among different filtering scales. Afterward, intensity gradients of each interest point are summarized by 64 features at certain locations and scales. A frame feature vector is built by concatenating statistics of each feature of the 15 groups of scales. Then, binary classification is performed by Support Vector Machine and Adaboost models. Evaluation was performed using a data set with 55 subjects, 18 of PC class (16,585 frames), and 37 subjects of non-PC class (49,664 frames), randomly splitting ten times. The proposed method reached an accuracy of 92.1%, sensitivity of 96.3%, and specificity of 87.8.3%. The observed results are also stable in noisy experiments while deep learning approaches fail to maintain similar performance.

---

### Requirements

- MATLAB platform v. 2020b or newer releases.
- If you want to use the collection of videos presented in this work, please refer to the work ''Endoscopic ultrasound database of the pancreas'' in (https://doi.org/10.1117/12.2581321).

---

### Reproduce our results

The results of this work are reproduced in this repository using computed feature vectors (located in ./Our results/RESULTS/Threshold_500_Preprocessed_Image folder) from the database presented in this work. These feature vectors include the Preprocessing and Describing the Regions of Interest steps of the methodology. Such features are used to build the feature matrix and train/test the classification models of our method.

Steps to follow:

	- In the script ./code/main_our_results.m edits the main_root variable with the path where you cloned or downloaded the repository.
    - Run in MATLAB the script ./code/main_our_results.m

---

### Run the complete methodology

An example to run each step of the methodology. This process is executed in the following order:

1. Process a complete video
2. Extract the frames
3. Transform the frames from cartesian coordinates to polar and apply the preprocessing step.
4. Apply the SURF detector and descriptor
5. Construct the feature vector
6. Train and test the models
7. Correct the miss-classification frames

Steps to follow:

    - The repository has three videos per class to execute the complete methodology in the script ./code/main_example.m. But, if you want to test the method with your own data, first you need to generate a new mat file ./Example/RESULTS/train_iterations.mat with the distribution of your data for training and testing, following the original structure of the mat file. Then, your own video collection of Endoscopy Ultrasound must be stored in the path ./Example/Videos and distributed between the CANCER and HEALTHY PANCREAS folders according to the video's label in the new ./Example/RESULTS/train_iterations.mat.
	- Also, in the script ./code/main_example.m edits the main_root variable with the path where you cloned or downloaded the repository.
    - Run in MATLAB the script ./code/main_example.m

### Endoscopic ultrasound database

At the link below you can request access to the database.

https://forms.gle/WD4DtMhMboLZ9pgVA

### References

- Ruano, J., Jaramillo, M., Gómez, M., & Romero, E. (2022). Robust descriptor of pancreatic tissue for automatic detection of pancreatic cancer in endoscopic ultrasonography. Ultrasound in Medicine & Biology, 48(8), 1602-1614.
- Jaramillo, M., Ruano, J., Gómez, M., & Romero, E. (2020, November). Endoscopic ultrasound database of the pancreas. In 16th International Symposium on Medical Information Processing and Analysis (Vol. 11583, pp. 130-135). SPIE.
