//  Copyright © 2015 Venture Media Labs. All rights reserved.

#import <Foundation/Foundation.h>

//! Project version number for HDF5.
FOUNDATION_EXPORT double HDF5VersionNumber;

//! Project version string for HDF5.
FOUNDATION_EXPORT const unsigned char HDF5VersionString[];

#import <HDF5Kit/H5Apublic.h>
#import <HDF5Kit/H5ACpublic.h>
#import <HDF5Kit/H5Bpublic.h>
#import <HDF5Kit/H5B2public.h>
#import <HDF5Kit/H5Dpublic.h>
#import <HDF5Kit/H5Epublic.h>
#import <HDF5Kit/H5Fpublic.h>
#import <HDF5Kit/H5FDpublic.h>
#import <HDF5Kit/H5FSpublic.h>
#import <HDF5Kit/H5Gpublic.h>
#import <HDF5Kit/H5HFpublic.h>
#import <HDF5Kit/H5HGpublic.h>
#import <HDF5Kit/H5HLpublic.h>
#import <HDF5Kit/H5MMpublic.h>
#import <HDF5Kit/H5Ppublic.h>
#import <HDF5Kit/H5PLpublic.h>
#import <HDF5Kit/H5Rpublic.h>
#import <HDF5Kit/H5Spublic.h>
#import <HDF5Kit/H5Tpublic.h>
#import <HDF5Kit/H5Zpublic.h>

static inline hid_t HDF5Kit_H5T_NATIVE_LONG(void) { return H5T_NATIVE_LONG_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_ULONG(void) { return H5T_NATIVE_ULONG_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_FLOAT(void) { return H5T_NATIVE_FLOAT_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_DOUBLE(void) { return H5T_NATIVE_DOUBLE_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_INT8(void) { return H5T_NATIVE_INT8_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_UINT8(void) { return H5T_NATIVE_UINT8_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_INT16(void) { return H5T_NATIVE_INT16_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_UINT16(void) { return H5T_NATIVE_UINT16_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_INT32(void) { return H5T_NATIVE_INT32_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_UINT32(void) { return H5T_NATIVE_UINT32_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_INT64(void) { return H5T_NATIVE_INT64_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_UINT64(void) { return H5T_NATIVE_UINT64_g; }
static inline hid_t HDF5Kit_H5T_NATIVE_OPAQUE(void) { return H5T_NATIVE_OPAQUE_g; }
static inline hid_t HDF5Kit_H5T_C_S1(void) { return H5T_C_S1_g; }
static inline hid_t HDF5Kit_H5P_CLS_DATASET_CREATE_ID(void) { return H5P_CLS_DATASET_CREATE_ID_g; }
static inline hid_t HDF5Kit_H5P_CLS_LINK_CREATE_ID(void) { return H5P_CLS_LINK_CREATE_ID_g; }
