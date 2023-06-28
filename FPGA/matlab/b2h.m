txt_filename = 'instructions.txt';
out_filename = 'instructions_hex.txt';

txt_data = textread(txt_filename,'%s');
fid=fopen(out_filename, 'wt');

dec_data = bin2dec (txt_data);
hex_data = dec2hex (dec_data);

[m,n] = size( hex_data );

for i = 1 : m
    fprintf(fid, '%s', hex_data(i,:)  );
end