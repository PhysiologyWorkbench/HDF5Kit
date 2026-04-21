#ifndef CHDF5_h
#define CHDF5_h

#include "../../../dist/src/hdf5.h"

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

#endif /* CHDF5_h */
