m4_divert(-1)
m4_changecom(`##')
m4_changequote(`/*', `*/')
m4_define(/*SKIP*/, /*$@*/)
m4_define(/*tr*/, /*m4_translit(/*$1*/, /*
*/)*/)
m4_divert(0)
m4_patsubst(/*tr(m4_esyscmd(realpath m4___file__))*/, .\(\.\).*, \1)
