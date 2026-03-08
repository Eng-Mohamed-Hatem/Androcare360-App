#!/bin/bash

##############################################################################
# AndroCare360 Test Environment Setup Script
# 
# This script automates the complete test environment setup:
# 1. Checks prerequisites
# 2. Installs dependencies
# 3. Starts Firebase Emulator (if using emulator)
# 4. Creates test accounts (doctors & patients)
# 5. Creates test appointments
# 6. Verifies the setup
#
# Usage:
#   ./scripts/setup_test_environment.sh [emulator|dev|prod]
#
# Example:
#   ./scripts/setup_test_environment.sh emulator
#
##############################################################################

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default environment
ENVIRONMENT="${1:-emulator}"

# Validate environment
if [[ ! "$ENVIRONMENT" =~ ^(emulator|dev|prod)$ ]]; then
    echo -e "${RED}❌ Invalid environment. Use: emulator, dev, or prod${NC}"
    exit 1
fi

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════════╗"
echo "║     AndroCare360 Test Environment Setup                   ║"
echo "║     Environment: $ENVIRONMENT                                        ║"
echo "╚════════════════════════════════════════════════════════════╝"
echo -e "${NC}"

##############################################################################
# Step 1: Check Prerequisites
##############################################################################

echo -e "${YELLOW}[1/6] Checking Prerequisites...${NC}"

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Flutter installed${NC}"

# Check Firebase CLI (only required for emulator)
if [ "$ENVIRONMENT" == "emulator" ]; then
    if ! command -v firebase &> /dev/null; then
        echo -e "${RED}❌ Firebase CLI not found. Please install: npm install -g firebase-tools${NC}"
        exit 1
    fi
    echo -e "${GREEN}✅ Firebase CLI installed${NC}"
fi

# Check Dart
if ! command -v dart &> /dev/null; then
    echo -e "${RED}❌ Dart not found${NC}"
    exit 1
fi
echo -e "${GREEN}✅ Dart installed${NC}"

echo ""

##############################################################################
# Step 2: Install Dependencies
##############################################################################

echo -e "${YELLOW}[2/6] Installing Flutter Dependencies...${NC}"
flutter pub get
echo -e "${GREEN}✅ Dependencies installed${NC}"
echo ""

##############################################################################
# Step 3: Start Firebase Emulator (if using emulator)
##############################################################################

if [ "$ENVIRONMENT" == "emulator" ]; then
    echo -e "${YELLOW}[3/6] Checking Firebase Emulator...${NC}"
    
    # Check if emulator is already running
    if curl -s http://localhost:4000 > /dev/null 2>&1; then
        echo -e "${GREEN}✅ Firebase Emulator already running${NC}"
    else
        echo -e "${RED}❌ Firebase Emulator is not running!${NC}"
        echo -e "${YELLOW}Please start the emulator in another terminal:${NC}"
        echo -e "  ${BLUE}firebase emulators:start${NC}"
        echo ""
        echo -e "${YELLOW}Then run this script again.${NC}"
        exit 1
    fi
else
    echo -e "${YELLOW}[3/6] Skipping Emulator (using $ENVIRONMENT)${NC}"
fi

echo ""

##############################################################################
# Step 4: Create Test Accounts
##############################################################################

echo -e "${YELLOW}[4/6] Creating Test Accounts...${NC}"
dart scripts/create_test_accounts.dart --environment "$ENVIRONMENT"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test accounts created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create test accounts${NC}"
    exit 1
fi

echo ""

# Wait a bit for Firestore to sync
echo -e "${YELLOW}⏳ Waiting for Firestore to sync...${NC}"
sleep 2
echo ""

##############################################################################
# Step 5: Create Test Appointments
##############################################################################

echo -e "${YELLOW}[5/6] Creating Test Appointments...${NC}"
dart scripts/create_test_appointments.dart --environment "$ENVIRONMENT"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Test appointments created successfully${NC}"
else
    echo -e "${RED}❌ Failed to create test appointments${NC}"
    exit 1
fi

echo ""

##############################################################################
# Step 6: Verify Setup
##############################################################################

echo -e "${YELLOW}[6/6] Verifying Test Environment...${NC}"
dart scripts/verify_test_environment.dart --environment "$ENVIRONMENT"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}"
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║  🎉 Test Environment Setup Complete!                      ║"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [ "$ENVIRONMENT" == "emulator" ]; then
        echo -e "${BLUE}📋 Quick Access Links:${NC}"
        echo "  - Firestore UI: http://localhost:4000/firestore"
        echo "  - Auth UI: http://localhost:4000/auth"
        echo "  - Functions Logs: http://localhost:4000/logs"
        echo ""
    fi
    
    echo -e "${BLUE}📝 Test Credentials:${NC}"
    echo "  Doctors: doctor.test1@androcare360.test (password: TestDoctor123!)"
    echo "  Patients: patient.test1@androcare360.test (password: TestPatient123!)"
    echo ""
    echo -e "${GREEN}✅ Ready to proceed with testing!${NC}"
else
    echo -e "${RED}❌ Verification failed. Please review errors above.${NC}"
    exit 1
fi
