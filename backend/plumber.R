library(here)
library(jsonlite)

# Load exported parameters aand metadata from JSON
# JSON allows model information to be accessed independently
# and not depend on serialized R model objects (.rds files)
bundle <- read_json(here("backend", "models", "lr_bundle.json"),
                    simplifyVector = FALSE)
calculate_bmi <- function(height, weight) {
    # Convert height from centimeters to meters
    height_m <- height / 100
    bmi <- weight / (height_m ^ 2)
    return(bmi)
}

predict_logistic <- function(model_info, input_data) {
    prediction <- model_info$intercept + input_data$age * model_info$coefficients[["age"]] +
        input_data$height * model_info$coefficients[["height"]] +
        input_data$bmi * model_info$coefficients[["bmi"]] +
        input_data$menopause_age * model_info$coefficients[["menopause_age"]]

    probability <- 1 / (1 + exp(-prediction))
    return(probability)
}
predict_all <- function(input_data) {
    predictions <- list()
    for (outcome in names(bundle$models)) {
        model_info <- bundle$models[[outcome]]
        predictions[[outcome]] <- predict_logistic(model_info, input_data)
    }
    return(predictions)
}

#* @post /predict
#* @param age:numeric
#* @param height:numeric
#* @param weight:numeric
#* @param menopause_age:numeric
function(age, height, weight, menopause_age = NULL) {



    #exclude inputs that does not make sense for the model, throw error if any of these conditions are met
    #later, send warning for inputs that are outside of the training data range, but still within a reasonable range
    if (age < 18 || age > 120) {
        stop("Age must be between 18 and 120.");
    } else if (height < 100 || height > 250) {
        stop("Height must be between 100 and 250 cm.");
    } else if (weight < 30 || weight > 300) {
        stop("Weight must be between 30 and 300 kg.");
    } else if (!is.null(menopause_age) && (menopause_age < 18 || menopause_age > 65)) {
        stop("Menopause age must be between 18 and 65.");
    } else if (!is.null(menopause_age) && (menopause_age > age)) {
        stop("Menopause age cannot exceed current age.");
    }

    if (is.null(menopause_age)) {
        menopause_age <- bundle$menopause_age_fill;
    }

    #calculate BMI from height and weight
    bmi <- calculate_bmi(height, weight)
    
    
    # weight excluded because it exists in bmi, part of the model bundle
    input_data <- data.frame(
        age = age,
        height = height,
        bmi = bmi,
        menopause_age = menopause_age
    )


    # Return the predictions
    return(predict_all(input_data))
}