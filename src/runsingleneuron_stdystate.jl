
function _oscintegrator_stdystate(wts::Wts,
                            netparams::NetParams,
                            runparams::RunParamsStdyState,
                            simvals::SimVals,
                            integratornode::SingleIntegratorNode
                            )

    a=0
    b=0
    dt = runparams.dt
    oscinput = 0.0

    kn1 = 0.0
    kh1 = 0.0
    kv1 = 0.0

    kn2 = 0.0
    kh2 = 0.0
    kv2 = 0.0

    kn3 = 0.0
    kh3 = 0.0
    kv3 = 0.0

    kn4 = 0.0
    kh4 = 0.0
    kv4 = 0.0

    integratornode.s = runparams.I_ext

    for t = simvals.t_vect
        a+=1

        #Calculate whether there has been a spike
        integratornode.spikeyesno, integratornode.vstore = spiketest(   integratornode.vstore,
                                                                        integratornode.v,
                                                                        netparams.spike_threshold
        );
        #Store spike time if there was a spike
        if integratornode.spikeyesno == 1
            integratornode.spikes_vect[a] = t
        end

        oscinput = I(t, runparams.gamma_I_t, runparams.omega_I_t) 



        ### Runge steps ###
        #step 1
        kn1 = dt * dndt(integratornode.n, netparams.phi, integratornode.v)
        kh1 = dt * dhdt(integratornode.h, netparams.phi, integratornode.v)
        kv1 = dt * dvdt(integratornode.v, netparams.g_L, netparams.E_L, 
                        integratornode.h, netparams.g_Na, netparams.E_Na, 
                        integratornode.n, netparams.g_K, netparams.E_K,
                        integratornode.s, netparams.g_syn, wts.w_EE,
                        runparams.I_O, oscinput, integratornode.noise, 0.0,
                        netparams.C_m
        )
        #step 2
        kn2 = dt * dndt(integratornode.n + kn1/2, netparams.phi, integratornode.v + kv1/2)
        kh2 = dt * dhdt(integratornode.h + kh1/2, netparams.phi, integratornode.v + kv1/2)
        kv2 = dt * dvdt(integratornode.v + kv1/2, netparams.g_L, netparams.E_L, 
                        integratornode.h + kh1/2, netparams.g_Na, netparams.E_Na, 
                        integratornode.n + kn1/2, netparams.g_K, netparams.E_K,
                        integratornode.s, netparams.g_syn, wts.w_EE,
                        runparams.I_O, oscinput, integratornode.noise, 0.0,
                        netparams.C_m
        )
        #step 3
        kn3 = dt * dndt(integratornode.n + kn2/2, netparams.phi, integratornode.v + kv2/2)
        kh3 = dt * dhdt(integratornode.h + kh2/2, netparams.phi, integratornode.v + kv2/2)
        kv3 = dt * dvdt(integratornode.v + kv2/2, netparams.g_L, netparams.E_L, 
                        integratornode.h + kh2/2, netparams.g_Na, netparams.E_Na, 
                        integratornode.n + kn2/2, netparams.g_K, netparams.E_K,
                        integratornode.s, netparams.g_syn, wts.w_EE,
                        runparams.I_O, oscinput, integratornode.noise, 0.0,
                        netparams.C_m
        )
        #step 4
        kn4 = dt * dndt(integratornode.n + kn3, netparams.phi, integratornode.v + kv3)
        kh4 = dt * dhdt(integratornode.h + kh3, netparams.phi, integratornode.v + kv3)
        kv4 = dt * dvdt(integratornode.v + kv3, netparams.g_L, netparams.E_L, 
                        integratornode.h + kh3, netparams.g_Na, netparams.E_Na, 
                        integratornode.n + kn3, netparams.g_K, netparams.E_K,
                        integratornode.s, netparams.g_syn, wts.w_EE,
                        runparams.I_O, oscinput, integratornode.noise, 0.0,
                        netparams.C_m
        )
        #reduction
        integratornode.n = integratornode.n + (kn1 + 2*kn2 + 2*kn3 + kn4)/6
        integratornode.h = integratornode.h + (kh1 + 2*kh2 + 2*kh3 + kh4)/6
        integratornode.v = integratornode.v + (kv1 + 2*kv2 + 2*kv3 + kv4)/6



        # Downsample storage for plotting
        if mod(a,runparams.downsamplespacing) == 0
            b += 1;
            integratornode.v_vect[b] = integratornode.v; 
            integratornode.s_vect[b] = integratornode.s; 
            simvals.plot_t_vect[b] = simvals.t_vect[a]; 
        end

    end

    return simvals, integratornode

end
