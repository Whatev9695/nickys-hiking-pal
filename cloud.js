(function(){
  const cfg=window.NHP_CONFIG||{},configured=Boolean(cfg.supabaseUrl&&cfg.supabaseAnonKey&&window.supabase);
  let client=null,user=null,timer=null,loading=false;
  const listeners=[];
  const emit=event=>listeners.forEach(fn=>fn(event,{configured,user}));
  async function init(){
    if(!configured){emit("unavailable");return}
    client=window.supabase.createClient(cfg.supabaseUrl,cfg.supabaseAnonKey,{auth:{persistSession:true,autoRefreshToken:true}});
    const {data}=await client.auth.getSession();user=data.session?.user||null;
    client.auth.onAuthStateChange(async(event,session)=>{user=session?.user||null;emit(user?"signed-in":"signed-out");if(user)await load()});
    emit(user?"signed-in":"signed-out");if(user)await load()
  }
  async function load(){
    if(!client||!user)return;loading=true;emit("syncing");
    const {data,error}=await client.from("app_states").select("data,updated_at").eq("user_id",user.id).maybeSingle();
    loading=false;
    if(error){const local=window.loadUserLocalData?.(user.id);if(local&&window.applyCloudData)window.applyCloudData(local);emit("error");return}
    if(data?.data&&window.applyCloudData){
      const local=window.loadUserLocalData?.(user.id),localTime=Date.parse(local?.meta?.updatedAt||0),cloudTime=Date.parse(data.data?.meta?.updatedAt||data.updated_at||0);
      if(localTime>cloudTime){window.applyCloudData(local);await syncNow();emit("local-newer")}else{window.applyCloudData(data.data);emit("loaded")}
    }else{window.prepareNewCloudUser?.();emit("empty-cloud")}
  }
  async function syncNow(){
    if(!client||!user||loading||!window.getAppData)return false;emit("syncing");
    const {error}=await client.from("app_states").upsert({user_id:user.id,data:window.getAppData(),updated_at:new Date().toISOString()});
    emit(error?"error":"synced");return !error
  }
  function queue(){if(!client||!user||loading)return;clearTimeout(timer);timer=setTimeout(syncNow,900)}
  async function signIn(email,password){return client.auth.signInWithPassword({email,password})}
  async function signUp(email,password,displayName){return client.auth.signUp({email,password,options:{data:{display_name:displayName}}})}
  async function signOut(){return client.auth.signOut()}
  async function groups(){if(!client||!user)return[];const {data}=await client.from("group_members").select("role,groups(id,name,invite_code,owner_id)").eq("user_id",user.id);return(data||[]).map(x=>({...x.groups,role:x.role}))}
  async function createGroup(name){return client.rpc("create_hiking_group",{name_input:name})}
  async function joinGroup(code){return client.rpc("join_hiking_group",{code_input:code.trim().toUpperCase()})}
  async function sharedPlans(groupId){const {data}=await client.from("shared_plans").select("*").eq("group_id",groupId).order("created_at",{ascending:false});return data||[]}
  async function sharePlan(groupId,plan){return client.from("shared_plans").insert({group_id:groupId,owner_id:user.id,name:plan.name,location:plan.location,target_date:plan.date||null,details:plan})}
  window.HikingCloud={configured,init,queue,syncNow,signIn,signUp,signOut,groups,createGroup,joinGroup,sharedPlans,sharePlan,on:fn=>listeners.push(fn),get user(){return user}};
})();
