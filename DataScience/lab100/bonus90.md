# LAB 100-90 (Optional): Engineering a new input feature

![Workshop Data Science](../commonimages/workshop_logo.png)

Feature Engineering is the process of creating/updating input features using Domain Knowledge. The goal is to calculate / derive new features and explore if it has a higher predictive significance.

## Investigate the garage attributes

Remember how we saw that there are a few very similar attributes for garage, namely GarageArea and GarageCars? We will try to remove the colinearity of these by combining them into one attribute and see if this improves the model. Let's check the relationship of the two attributes to the `SalePrice`.

```python
plot.scatter(alldata.GarageArea, alldata.SalePrice)
plot.xlabel("GarageArea")
plot.ylabel("SalePrice")
plot.show()
print ('Correlation of GarageArea with SalePrice: ', alldata['GarageArea'].corr(alldata['SalePrice']))

plot.scatter(alldata.GarageCars, alldata.SalePrice)
plot.xlabel("GarageCars")
plot.ylabel("SalePrice")
plot.show()
print ('Correlation of GarageCars with SalePrice: ', alldata['GarageCars'].corr(alldata['SalePrice']))
```

The plots give us some basic understanding about the data distribution. We can see that the price of a house increases with higher `GarageArea` but it is not nessery the case if we compare it with the relation between `GarageCars` to `SalePrice`. This means that the two features are relevant to keep but not conclusive enough, other factors like the garage quality, interior finish and more could play importnat role.

Since the correlation matrix shown high collinearity, let's come up with a single metric for parking by -multiplying- `GarageArea` and `GarageCars` and try this new feature in our model.

```python
alldata['GarageArea_x_Car'] = alldata.GarageArea * alldata.GarageCars

plot.scatter(alldata.GarageArea_x_Car, alldata.SalePrice)
plot.xlabel("GarageArea_x_Car")
plot.ylabel("SalePrice")
plot.show()
print ('Correlation of GarageArea_x_Car with SalePrice: ', alldata['GarageArea_x_Car'].corr(alldata['SalePrice']))
```

`Conclusion`: The newly engineered feature does not appear to delivers better relationship to the sale price than `GarageArea` or `GarageCars` alone, at least it is not visiable from the plot.

## Remove the original garage attributes, rebuild the model and compare

With the new attribute in place, let's train the model again, and compare its performance with the original model. We will remove `GarageArea` and `GarageCars` and use only the newly calculation feature, which is called `GarageArea_x_Car`. The column is already presented in the data, so we don't have to add it again.

```python
X.drop("GarageArea", axis = 1, inplace = True)
X.drop("GarageCars", axis = 1, inplace = True)

X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=63, test_size=.20)
lr = linear_model.LinearRegression()
model = lr.fit(X_train, y_train)
y_predicted = model.predict(X_test)
print('RMSE: ', mean_squared_error(y_test, y_predicted))
```

We could see that the new RMSE value does not show any signinficant improvement, the result is even worst. Remember **collinearity does not necessary mean causality!**

## Conclusion

In our case it seems that `GarageArea` and `GarageCars` are better predictors used separatly than combined. Part of the daily data scientist job will be to analyse the features and search for predictors that could help the model generalize better and improve the model scores like the RMSE.

## Follow-up questions

![Lyudmil Pelov](../commonimages/lyudmil.png)
[lyudmil.x.pelov@oracle.com](mailto:lyudmil.x.pelov@oracle.com)

![Jeroen Klosterman](../commonimages/jeroen.png)
[jeroen.kloosterman@oracle.com](mailto:jeroen.kloosterman@oracle.com)