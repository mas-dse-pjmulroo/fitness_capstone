
# coding: utf-8

# In[1]:

from  pyspark.ml.feature import MinMaxScaler
from pyspark import SparkContext

#minMaxScaler wrapper since originalMin/Max is only implemented in 2.0
class mmscaler_wrapper():
    mmModel = ''
    originalMin = ''
    originalMax = ''   
    
    def __init__(self, inputCol, outputCol, s_min = 0, s_max = 0):
        self.mmModel = MinMaxScaler(inputCol=inputCol, outputCol=outputCol)
        self.mmModel.setMin(s_min)
        self.mmModel.setMax(s_max)
        self.in_column = inputCol
        
    def get_input_col_name(self):
        return self.mmModel.getInputCol()

    def getMax(self):
        return self.mmModel.getMax()
        
    def getMin(self):
        return self.mmModel.getMin()
    
    def describe(self):
        print 'describe'
    
    def fit(self, df):
        col = self.mmModel.getInputCol()
        self.originalMin = df.select(col).rdd.flatMap(lambda x: x[0]).min()
        self.originalMax = df.select(col).rdd.flatMap(lambda x: x[0]).max()
        return self.mmModel.fit(df)
    
    #denormalize the value
    def denormalize(self, value):
        v = (value-self.getMin())*            (self.originalMax - self.originalMin)*            (self.getMax()-self.getMin()) + self.originalMin
        if v or v == 0:
            return v
        else:
            return -999
        
    def denormalize_df(self, df):
        col = self.mmModel.getInputCol()
        
        
    def normalize(self, value):
        pass


# In[ ]:



