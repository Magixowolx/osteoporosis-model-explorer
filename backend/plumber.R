library(here)
library(jsonlite)

#* Enable CORS for frontend requests
#* @filter cors
cors <- function(req, res) {
    # use * to allow all origins during development
    res$setHeader("Access-Control-Allow-Origin", "*")
    res$setHeader("Access-Control-Allow-Methods", "POST, GET, OPTIONS")
    res$setHeader("Access-Control-Allow-Headers", "Content-Type")
    if (req$REQUEST_METHOD == "OPTIONS") {
        res$status <- 200
        return(list())
    }
    plumber::forward()
}
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

# return a binary classification based on the cutoff for each outcome
cutoff_comparison <- function(predictions, cutoffs) {
    results <- list()
    for (outcome in names(predictions)) {
        results[[outcome]] <- ifelse(predictions[[outcome]] >= cutoffs[[outcome]], 1, 0)
    }
    return(results)
}


# allow cutoff choice of sens90 or youden's index

#* @post /predict
#* @param cutoff:string
#* @param age:numeric
#* @param height:numeric
#* @param weight:numeric
#* @param menopause_age:numeric
function(cutoff = "sens90", age = NULL, height = NULL, weight = NULL,
         menopause_age = NULL, res) {
    
    age = suppressWarnings(as.numeric(age))
    height = suppressWarnings(as.numeric(height))
    weight = suppressWarnings(as.numeric(weight))
    if (!is.null(menopause_age)) {
        menopause_age = suppressWarnings(as.numeric(menopause_age))
    }

    # validate inputs and return error if any of the inputs are invalid
    if (length(age) != 1L || !is.finite(age)) {
        res$status <- 400
        return(list(error = "Age must be a valid number."))
    } else if (length(height) != 1L || !is.finite(height)) {
        res$status <- 400
        return(list(error = "Height must be a valid number."))
    } else if (length(weight) != 1L || !is.finite(weight)) {
        res$status <- 400
        return(list(error = "Weight must be a valid number."))
    } else if (!is.null(menopause_age) &&
               (length(menopause_age) != 1L || !is.finite(menopause_age))) {
        res$status <- 400
        return(list(error = "Menopause age must be a valid number."))
    }

    #exclude inputs that does not make sense for the model, throw error if any of these conditions are met
    #later, send warning for inputs that are outside of the training data range, but still within a reasonable range
    if (age < 18 || age > 120) {
        res$status <- 400
        return(list(error = "Age must be between 18 and 120."));
    } else if (height < 100 || height > 250) {
        res$status <- 400
        return(list(error = "Height must be between 100 and 250 cm."));
    } else if (weight < 30 || weight > 300) {
        res$status <- 400
        return(list(error = "Weight must be between 30 and 300 kg."));
    } else if (!is.null(menopause_age) && (menopause_age < 18 || menopause_age > 65)) {
        res$status <- 400
        return(list(error = "Menopause age must be between 18 and 65."));
    } else if (!is.null(menopause_age) && (menopause_age > age)) {
        res$status <- 400
        return(list(error = "Menopause age cannot exceed current age."))
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

    probabilities <- predict_all(input_data)
    #
    cutoffs <- lapply(bundle$models, function(model_info) {
        model_info$cutoffs[[cutoff]]$cutoff
    })
    classifications <- cutoff_comparison(probabilities, cutoffs)

    list(
        probabilities = probabilities,
        classifications = classifications
    )
}