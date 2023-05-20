clear all;
clear global;

pkg load instrument-control

# If unsure what your port is
#serialportlist

# Default 8N1 Format
# Wacky windows COM power >9 syntax required ap
device = serialport("\\\\.\\COM10", 115200)

# Flush I/O Buffers, probably not needed but can't hurt
flushinput(device);
flushoutput(device);


NUM_VALS = 32;

# Generate 32 random values
random_vals = int32(randi([-64, 64], [1, NUM_VALS]));
#random_vals = int32(ones(NUM_VALS,1));

fid3 = fopen('txd_bytes.txt', 'w');

n = 0;
while n < NUM_VALS
  n = n + 1;
  T = random_vals(n);
  # Split our value into a byte array
  # Matlab style typecase/(lack of)pointers hurts here.
  V = typecast(T, "uint8");
  # Write LSB first over UART line
  write(device, V(1));
  write(device, V(2));
  write(device, V(3));
  write(device, V(4));
  # Record what has been sent for later reference
  fprintf(fid3, '%08X\t%02X %02X %02X %02X\n', T, V(1), V(2), V(3), V(4));
end

fclose(fid3);

# Read in bytes, format as int32, expects LSB first
fid2 = fopen('rxd_bytes.txt','w');
return_arr = read(device, NUM_VALS, "int32");

# Save return data to file for later reference
n = 0;
while n < NUM_VALS
  n = n + 1;
  fprintf(fid2, '%08X\n', return_arr(n));
end

fclose(fid2);

# Record error between TX and RX
fid = fopen('error_array.txt', 'w');
for n=1:NUM_VALS
  fprintf(fid, '%08X\n', return_arr(n) - random_vals(n));
end
fclose(fid);






#fclose(device);
