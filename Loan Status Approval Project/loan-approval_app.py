import streamlit as st
import numpy as np
import pandas as pd
from sklearn import svm
from sklearn.model_selection import train_test_split

def create_sample_dataset():
    """Create a sample dataset for model training"""
    data = {
        'Gender': ['Male', 'Male', 'Male', 'Male', 'Male', 'Female'] * 80,
        'Married': ['Yes', 'Yes', 'Yes', 'No', 'Yes', 'No'] * 80,
        'Dependents': ['1', '0', '0', '0', '2', '0'] * 80,
        'Education': ['Graduate', 'Graduate', 'Not Graduate', 'Graduate', 'Graduate', 'Graduate'] * 80,
        'Self_Employed': ['No', 'Yes', 'No', 'No', 'Yes', 'No'] * 80,
        'ApplicantIncome': [4583, 3000, 2583, 6000, 5417, 4583] * 80,
        'CoapplicantIncome': [1508, 0, 2358, 0, 4196, 1508] * 80,
        'LoanAmount': [128, 66, 120, 141, 267, 128] * 80,
        'Loan_Amount_Term': [360, 360, 360, 360, 360, 360] * 80,
        'Credit_History': [1, 1, 1, 1, 1, 1] * 80,
        'Property_Area': ['Rural', 'Urban', 'Urban', 'Urban', 'Urban', 'Rural'] * 80,
        'Loan_Status': ['Y', 'Y', 'Y', 'Y', 'Y', 'N'] * 80
    }
    return pd.DataFrame(data)

def load_and_train_model():
    # Create the sample dataset
    loan_dataset = create_sample_dataset()
    
    # Convert categorical columns to numerical values
    loan_dataset.replace({
        'Loan_Status':{'N':0,'Y':1},
        'Married':{'No':0,'Yes':1},
        'Gender':{'Male':1,'Female':0},
        'Self_Employed':{'No':0,'Yes':1},
        'Property_Area':{'Rural':0,'Semiurban':1,'Urban':2},
        'Education':{'Graduate':1,'Not Graduate':0}
    }, inplace=True)
    
    # Replace '3+' with 4 in Dependents
    loan_dataset['Dependents'] = loan_dataset['Dependents'].replace('3+', '4')
    loan_dataset['Dependents'] = loan_dataset['Dependents'].astype(int)
    
    # Separate features and target
    X = loan_dataset.drop(columns=['Loan_Status'])
    Y = loan_dataset['Loan_Status']
    
    # Train the model
    X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.1, stratify=Y, random_state=2)
    classifier = svm.SVC(kernel='linear')
    classifier.fit(X_train, Y_train)
    
    return classifier

def main():
    # Page configuration
    st.set_page_config(
        page_title="Loan Status Prediction",
        layout="centered",
        initial_sidebar_state="collapsed"
    )
    
    # Custom CSS for better styling
    st.markdown("""
        <style>
        .main {
            padding: 2rem;
        }
        .stButton>button {
            width: 100%;
            margin-top: 20px;
        }
        </style>
    """, unsafe_allow_html=True)
    
    # Header
    st.title("🏦 Loan Status Prediction")
    st.write("""
    Find out if you're eligible for a loan by entering your information below.
    This model uses machine learning to predict loan approval status.
    """)
    
    # Create input columns for better layout
    col1, col2 = st.columns(2)
    
    with col1:
        st.subheader("Personal Information")
        gender = st.selectbox('Gender', ['Male', 'Female'])
        married = st.selectbox('Married', ['Yes', 'No'])
        dependents = st.selectbox('Dependents', ['0', '1', '2', '4'])
        education = st.selectbox('Education', ['Graduate', 'Not Graduate'])
        self_employed = st.selectbox('Self Employed', ['Yes', 'No'])
        
    with col2:
        st.subheader("Loan & Property Information")
        applicant_income = st.number_input('Applicant Income (monthly)', min_value=0, value=5000)
        coapplicant_income = st.number_input('Coapplicant Income (monthly)', min_value=0, value=0)
        loan_amount = st.number_input('Loan Amount (in thousands)', min_value=9, value=100)
        loan_term = st.selectbox('Loan Term (months)', [360, 180, 480, 240, 120, 60, 36, 12])
        credit_history = st.selectbox('Credit History', [1, 0], 
                                    help="0: No credit history, 1: Has credit history")
        property_area = st.selectbox('Property Area', ['Rural', 'Semiurban', 'Urban'])

    # Convert inputs to model format
    input_dict = {
        'Gender': 1 if gender == 'Male' else 0,
        'Married': 1 if married == 'Yes' else 0,
        'Dependents': int(dependents),
        'Education': 1 if education == 'Graduate' else 0,
        'Self_Employed': 1 if self_employed == 'Yes' else 0,
        'ApplicantIncome': applicant_income,
        'CoapplicantIncome': coapplicant_income,
        'LoanAmount': loan_amount,
        'Loan_Amount_Term': loan_term,
        'Credit_History': credit_history,
        'Property_Area': {'Rural': 0, 'Semiurban': 1, 'Urban': 2}[property_area]
    }
    
    # Create features array for prediction
    features = pd.DataFrame([input_dict])
    
    # Add a progress bar for model loading
    if st.button('Predict Loan Status'):
        with st.spinner('Analyzing your application...'):
            # Load and train model
            model = load_and_train_model()
            
            # Make prediction
            prediction = model.predict(features)
            
            # Show prediction with custom styling
            st.write('---')
            if prediction[0] == 1:
                st.success('✅ Congratulations! Your loan is likely to be approved!')
                st.balloons()
                
                st.info("""
                **Favorable factors in your application:**
                - Credit History: {}
                - Income Level: ₹{:,}/month
                - Loan Term: {} months
                """.format(
                    "Good" if credit_history == 1 else "Limited",
                    applicant_income + coapplicant_income,
                    loan_term
                ))
            else:
                st.error('❌ Sorry, your loan is likely to be rejected.')
                st.warning("""
                **Tips to improve your chances:**
                1. Improve your credit history
                2. Increase your down payment
                3. Consider a co-applicant to increase total income
                4. Reduce the loan amount or extend the loan term
                5. Provide additional collateral
                """)

if __name__ == '__main__':
    main()
