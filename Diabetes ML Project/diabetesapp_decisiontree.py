import streamlit as st
import numpy as np
import pandas as pd
from sklearn.tree import DecisionTreeClassifier, plot_tree
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import pickle

# Page configuration
st.set_page_config(
    page_title="Diabetes Prediction - Decision Tree",
    page_icon="🌳",
    layout="wide"
)

# Title and description
st.title("Diabetes Prediction System using Decision Tree")
st.write("""
This application uses a Decision Tree algorithm to predict diabetes based on various health metrics.
The model provides both prediction and feature importance visualization.
""")

@st.cache_resource
def load_or_train_model():
    try:
        # Try to load the saved model
        with open('diabetes_dt_model.pkl', 'rb') as file:
            model = pickle.load(file)
        return model
    except:
        # If model doesn't exist, train a new one
        # Load the dataset
        df = pd.read_csv('diabetes.csv')
        
        # Separate features and target
        X = df.drop(columns='Outcome', axis=1)
        Y = df['Outcome']
        
        # Split the data
        X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2, stratify=Y, random_state=2)
        
        # Create and train model
        model = DecisionTreeClassifier(
            max_depth=5,
            min_samples_split=5,
            criterion='entropy'
        )
        model.fit(X_train, Y_train)
        
        # Save the model
        with open('diabetes_dt_model.pkl', 'wb') as file:
            pickle.dump(model, file)
        
        return model

# Load or train the model
model = load_or_train_model()

# Create two columns for the layout
col1, col2 = st.columns([2, 1])

with col1:
    st.header("Patient Information")
    
    # Create two sub-columns for input fields
    input_col1, input_col2 = st.columns(2)
    
    with input_col1:
        pregnancies = st.number_input("Number of Pregnancies", min_value=0, max_value=20, value=0)
        glucose = st.number_input("Glucose Level (mg/dL)", min_value=0, max_value=300, value=100)
        blood_pressure = st.number_input("Blood Pressure (mm Hg)", min_value=0, max_value=200, value=70)
        skin_thickness = st.number_input("Skin Thickness (mm)", min_value=0, max_value=100, value=20)
    
    with input_col2:
        insulin = st.number_input("Insulin Level (mu U/ml)", min_value=0, max_value=900, value=80)
        bmi = st.number_input("BMI", min_value=0.0, max_value=70.0, value=25.0)
        dpf = st.number_input("Diabetes Pedigree Function", min_value=0.0, max_value=3.0, value=0.5)
        age = st.number_input("Age", min_value=0, max_value=120, value=30)

with col2:
    st.header("Feature Importance")
    # Calculate and display feature importance
    feature_names = ['Pregnancies', 'Glucose', 'Blood Pressure', 'Skin Thickness', 
                    'Insulin', 'BMI', 'Diabetes Pedigree Function', 'Age']
    importance = model.feature_importances_
    
    # Create a DataFrame for feature importance
    feature_importance_df = pd.DataFrame({
        'Feature': feature_names,
        'Importance': importance
    }).sort_values(by='Importance', ascending=True)
    
    # Plot feature importance
    fig, ax = plt.subplots()
    ax.barh(feature_importance_df['Feature'], feature_importance_df['Importance'])
    ax.set_title('Feature Importance in Decision Tree Model')
    st.pyplot(fig)

# Create prediction button
if st.button("Predict Diabetes Status"):
    # Make prediction
    input_data = np.array([pregnancies, glucose, blood_pressure, skin_thickness, 
                          insulin, bmi, dpf, age]).reshape(1, -1)
    
    prediction = model.predict(input_data)
    prediction_proba = model.predict_proba(input_data)
    
    # Show prediction with custom styling
    st.header("Prediction Result")
    
    # Create three columns for the prediction display
    pred_col1, pred_col2, pred_col3 = st.columns(3)
    
    with pred_col1:
        if prediction[0] == 0:
            st.success("🎉 NON-DIABETIC")
        else:
            st.error("⚠️ DIABETIC")
    
    with pred_col2:
        st.metric(
            label="Confidence Score",
            value=f"{max(prediction_proba[0]) * 100:.2f}%"
        )
    
    # Display warning message
    st.warning("""
    **Note:** This prediction is based on a machine learning model and should not be used as a substitute 
    for professional medical diagnosis. Please consult with a healthcare provider for proper medical advice.
    """)
    
    # Show input data summary in an expander
    with st.expander("View Input Data Summary"):
        input_df = pd.DataFrame({
            'Feature': feature_names,
            'Value': [pregnancies, glucose, blood_pressure, skin_thickness, 
                     insulin, bmi, dpf, age]
        })
        st.table(input_df)

# Add information about the model
with st.expander("About the Model"):
    st.write("""
    This prediction model uses a Decision Tree algorithm with the following characteristics:
    - Maximum tree depth: 5
    - Minimum samples for split: 5
    - Criterion: Entropy
    
    Decision Trees are particularly useful for medical diagnosis because:
    - They're easily interpretable
    - Can handle both numerical and categorical data
    - Provide feature importance rankings
    - Don't require feature scaling
    """)

# Add footer
st.markdown("---")
st.markdown("""
<div style='text-align: center'>
    <p>Created with 🌳 using Streamlit and Decision Tree Algorithm</p>
</div>
""", unsafe_allow_html=True)