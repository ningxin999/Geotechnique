% Helper function for prediction
function FE_predict = makePrediction(AnParam, samples, ll, myPCE, PCA, kk)
    if AnParam.DR == "on"
        if AnParam.Surrogate == "custom"
            temp = custom_predict(samples, myPCE{kk}.psin, myPCE{kk}.psout, myPCE{kk}.lstmnet);
            FE_predict = temp(:, ll);
        else
            PCs_pred = uq_evalModel(myPCE{kk}, samples);
            FE_predict = PCs_pred * PCA{kk}.V(:, 1:PCA{kk}.number)' + PCA{kk}.mv;
        end
    else
        FE_predict = uq_evalModel(myPCE{kk}, samples);
    end
end